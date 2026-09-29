// ─── Complaint Service ─────────────────────────────────────────────────────────
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/complaint_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'notification_service.dart';

class ComplaintService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage   _storage   = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Generate Tracking ID ──────────────────────────────────────────────────────
  String _generateTrackingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${AppConstants.trackingPrefix}${timestamp.substring(timestamp.length - 4)}';
  }

  // ── Submit Complaint / Suggestion ─────────────────────────────────────────────
  Future<String?> submitComplaint({
    required String userId,
    required String? userName,
    String? studentRegNo,
    required String description,
    required String category,
    required String type,
    required String departmentId,
    required String departmentName,
    String priority = AppConstants.priorityNormal,
    required bool isAnonymous,
    File? imageFile,
  }) async {
    _setLoading(true);
    try {
      final trackingId = _generateTrackingId();
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, trackingId);
      }

      final now = DateTime.now();

      final complaint = ComplaintModel(
        complaintId:          trackingId,
        userId:               isAnonymous ? AppConstants.anonymousId : userId,
        userName:             isAnonymous ? null : userName,
        studentRegNo:         isAnonymous ? null : studentRegNo,
        title:                category,
        description:          description.trim(),
        category:             category,
        type:                 type,
        status:               AppConstants.statusPending,
        priority:             priority,
        isAnonymous:          isAnonymous,
        departmentId:         departmentId.trim(),
        departmentName:       departmentName.trim(),
        imageUrl:             imageUrl,
        referredToSuperAdmin: false,
        createdAt:            now,
        updatedAt:            now,
        statusHistory: [
          StatusHistory(
            status:          AppConstants.statusPending,
            action:          'Submitted',
            performedBy:     isAnonymous ? 'Anonymous Student' : (userName ?? 'Student'),
            performedByRole: 'Student',
            changedAt:       now,
            note:            'Submission received for $departmentName',
          ),
        ],
      );

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(trackingId)
          .set(complaint.toMap());

      // Notify Department Admins of this specific department
      await _notificationService.notifyDepartmentAdmins(
        departmentId:   departmentId.trim(),
        departmentName: departmentName.trim(),
        trackingId:     trackingId,
        type:           type,
        category:       category,
      );

      // Save confirmation notification for non-anonymous student
      if (!isAnonymous && userId != AppConstants.anonymousId) {
        await _notificationService.sendNotification(
          userId:       userId,
          title:        'Submission Received',
          body:         'Your $type ($trackingId) has been routed to $departmentName.',
          trackingId:   trackingId,
          type:         type,
          departmentId: departmentId,
        );
      }

      _setLoading(false);
      return trackingId;
    } catch (e) {
      _setLoading(false);
      debugPrint('ComplaintService.submitComplaint error: $e');
      return null;
    }
  }

  // ── Upload Image to Firebase Storage ─────────────────────────────────────────
  Future<String?> _uploadImage(File imageFile, String trackingId) async {
    try {
      final ref = _storage
          .ref()
          .child('complaint_images')
          .child('$trackingId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('ComplaintService._uploadImage: $e');
      return null;
    }
  }

  // ── Get Complaints by Role (Real-time Stream) ─────────────────────────────────
  /// - Student: their own complaints only
  /// - Department Admin: complaints for their departmentId ONLY
  /// - Super Admin: complaints that have been REFERRED to Super Admin ONLY
  Stream<List<ComplaintModel>> getComplaintsByRole(
    UserModel user, {
    String? typeFilter,
    String? statusFilter,
  }) {
    final collection = _firestore.collection(AppConstants.complaintsCollection);
    Query query;

    if (user.isSuperAdmin) {
      // Super Admin ONLY sees referred complaints in referral queue
      query = collection.where('referredToSuperAdmin', isEqualTo: true);
    } else if (user.isDepartmentAdmin) {
      // Department Admin ONLY sees complaints for their department
      final deptId = user.departmentId ?? '';
      final deptName = user.departmentName ?? '';

      if (deptId.isNotEmpty) {
        query = collection.where('departmentId', isEqualTo: deptId);
      } else {
        query = collection.where('department', isEqualTo: deptName);
      }
    } else {
      // Student only sees their own
      query = collection.where('userId', isEqualTo: user.uid);
    }

    return query.snapshots().map((snapshot) {
      var items = snapshot.docs
          .map((doc) => ComplaintModel.fromDocument(doc))
          .toList();

      if (typeFilter != null && typeFilter.isNotEmpty) {
        items = items.where((i) => i.type.toLowerCase() == typeFilter.toLowerCase()).toList();
      }

      if (statusFilter != null && statusFilter.isNotEmpty) {
        items = items.where((i) => i.status.toLowerCase() == statusFilter.toLowerCase()).toList();
      }

      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // ── Track by Tracking ID ──────────────────────────────────────────────────────
  Stream<ComplaintModel?> trackComplaint(String trackingId) {
    return _firestore
        .collection(AppConstants.complaintsCollection)
        .doc(trackingId.trim().toUpperCase())
        .snapshots()
        .map((doc) => doc.exists ? ComplaintModel.fromDocument(doc) : null);
  }

  // ── Update Status (Department Admin or Super Admin) ───────────────────────────
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    String? adminReply,
    required UserModel admin,
  }) async {
    try {
      final now = DateTime.now();
      final isResolved = newStatus == AppConstants.statusResolved;

      final history = StatusHistory(
        status:          newStatus,
        action:          'Status Changed to $newStatus',
        performedBy:     admin.name,
        performedByRole: admin.roleDisplay,
        changedAt:       now,
        note:            adminReply?.trim(),
      );

      final updateMap = <String, dynamic>{
        'status':        newStatus,
        'adminReply':    adminReply?.trim(),
        'repliedAt':     Timestamp.fromDate(now),
        'updatedAt':     Timestamp.fromDate(now),
        'statusHistory': FieldValue.arrayUnion([history.toMap()]),
      };

      if (isResolved) {
        updateMap['resolvedAt'] = Timestamp.fromDate(now);
      }

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(complaintId)
          .update(updateMap);

      // Fetch complaint to notify the student
      final doc = await _firestore.collection(AppConstants.complaintsCollection).doc(complaintId).get();
      if (doc.exists) {
        final complaint = ComplaintModel.fromDocument(doc);
        if (!complaint.isAnonymous && complaint.userId != AppConstants.anonymousId) {
          await _notificationService.notifyStudentStatusUpdate(
            studentId:  complaint.userId,
            trackingId: complaintId,
            newStatus:  newStatus,
            adminReply: adminReply,
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('ComplaintService.updateComplaintStatus: $e');
      return false;
    }
  }

  // ── Refer Complaint to Super Admin (Department Admin Action) ─────────────────
  Future<bool> referComplaintToSuperAdmin({
    required String complaintId,
    required String referralReason,
    required UserModel admin,
  }) async {
    try {
      final now = DateTime.now();

      final history = StatusHistory(
        status:          AppConstants.statusReferred,
        action:          'Referred to University Administration',
        performedBy:     admin.name,
        performedByRole: admin.roleDisplay,
        changedAt:       now,
        note:            referralReason.trim(),
      );

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(complaintId)
          .update({
        'status':               AppConstants.statusReferred,
        'referredToSuperAdmin':  true,
        'referredAt':           Timestamp.fromDate(now),
        'referringAdminId':     admin.uid,
        'referringAdminName':   admin.name,
        'referralReason':       referralReason.trim(),
        'updatedAt':            Timestamp.fromDate(now),
        'statusHistory':        FieldValue.arrayUnion([history.toMap()]),
      });

      // Fetch complaint details to get department name
      final doc = await _firestore.collection(AppConstants.complaintsCollection).doc(complaintId).get();
      final deptName = doc.data()?['departmentName'] ?? admin.departmentName ?? 'Department';

      // Notify Super Admins
      await _notificationService.notifySuperAdminsOnReferral(
        trackingId:         complaintId,
        departmentName:     deptName,
        referringAdminName: admin.name,
        reason:             referralReason.trim(),
      );

      return true;
    } catch (e) {
      debugPrint('ComplaintService.referComplaintToSuperAdmin error: $e');
      return false;
    }
  }

  // ── Real-time Analytics (Department Admin vs Super Admin) ─────────────────────
  Stream<Map<String, int>> getRealtimeAnalytics([UserModel? user]) {
    final collection = _firestore.collection(AppConstants.complaintsCollection);
    Query query;

    if (user != null && user.isDepartmentAdmin) {
      // Department Admin only gets their own department counts
      final deptId = user.departmentId ?? '';
      final deptName = user.departmentName ?? '';
      if (deptId.isNotEmpty) {
        query = collection.where('departmentId', isEqualTo: deptId);
      } else {
        query = collection.where('department', isEqualTo: deptName);
      }
    } else if (user != null && user.isSuperAdmin) {
      // Super Admin sees university-wide stats / referrals
      query = collection;
    } else {
      query = collection;
    }

    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();

      final pendingComplaints = docs.where((d) =>
        (d['type']?.toString().toLowerCase() == 'complaint') &&
        (d['status'] == AppConstants.statusPending)
      ).length;

      final pendingSuggestions = docs.where((d) =>
        (d['type']?.toString().toLowerCase() == 'suggestion') &&
        (d['status'] == AppConstants.statusPending)
      ).length;

      final inProgress = docs.where((d) => d['status'] == AppConstants.statusInProgress).length;
      final resolved = docs.where((d) => d['status'] == AppConstants.statusResolved).length;
      final referred = docs.where((d) => d['status'] == AppConstants.statusReferred || d['referredToSuperAdmin'] == true).length;
      final rejected = docs.where((d) => d['status'] == AppConstants.statusRejected).length;

      return {
        'total':              docs.length,
        'pending':            docs.where((d) => d['status'] == AppConstants.statusPending).length,
        'pendingComplaints':  pendingComplaints,
        'pendingSuggestions': pendingSuggestions,
        'inProgress':         inProgress,
        'resolved':           resolved,
        'referred':           referred,
        'rejected':           rejected,
      };
    });
  }

  // ── One-time Analytics Fetch ──────────────────────────────────────────────────
  Future<Map<String, int>> getAnalytics([UserModel? user]) async {
    try {
      final collection = _firestore.collection(AppConstants.complaintsCollection);
      Query query;

      if (user != null && user.isDepartmentAdmin) {
        final deptId = user.departmentId ?? '';
        final deptName = user.departmentName ?? '';
        if (deptId.isNotEmpty) {
          query = collection.where('departmentId', isEqualTo: deptId);
        } else {
          query = collection.where('department', isEqualTo: deptName);
        }
      } else {
        query = collection;
      }

      final snapshot = await query.get();
      final docs = snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();

      return {
        'total':      docs.length,
        'inProgress': docs.where((d) => d['status'] == AppConstants.statusInProgress).length,
        'resolved':   docs.where((d) => d['status'] == AppConstants.statusResolved).length,
        'pending':    docs.where((d) => d['status'] == AppConstants.statusPending).length,
      };
    } catch (e) {
      debugPrint('ComplaintService.getAnalytics error: $e');
      return {'total': 0, 'inProgress': 0, 'resolved': 0, 'pending': 0};
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

