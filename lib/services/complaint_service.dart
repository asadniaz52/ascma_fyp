// ─── Complaint Service ─────────────────────────────────────────────────────────
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/complaint_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class ComplaintService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage   _storage   = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Generate Tracking ID ──────────────────────────────────────────────────────
  String _generateTrackingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${AppConstants.trackingPrefix}${timestamp.substring(timestamp.length - 4)}';
  }

  // ── Submit Complaint / Suggestion ─────────────────────────────────────────────
  /// Saves a complaint/suggestion to Firestore.
  /// Strips userId to 'ANONYMOUS' if isAnonymous == true.
  Future<String?> submitComplaint({
    required String userId,
    required String? userName,
    required String description,
    required String category,
    required String type,
    required String department,
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

      final complaint = ComplaintModel(
        complaintId: trackingId,
        userId:      isAnonymous ? AppConstants.anonymousId : userId,
        userName:    isAnonymous ? null : userName,
        title:       category,
        description: description,
        category:    category,
        type:        type,
        status:      AppConstants.statusPending,
        isAnonymous: isAnonymous,
        createdAt:   DateTime.now(),
        department:  department,
        imageUrl:    imageUrl,
        statusHistory: [
          StatusHistory(
            status:    AppConstants.statusPending,
            changedAt: DateTime.now(),
            note:      'Submission received',
          ),
        ],
      );

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(trackingId)
          .set(complaint.toMap());

      // Save notification for non-anonymous user
      if (!isAnonymous && userId != AppConstants.anonymousId) {
        await _saveNotification(
          userId:      userId,
          trackingId:  trackingId,
          category:    category,
          type:        type,
        );
      }

      _setLoading(false);
      return trackingId; // Returns tracking ID on success
    } catch (e) {
      _setLoading(false);
      debugPrint('ComplaintService.submitComplaint: $e');
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

  // ── Save Notification ─────────────────────────────────────────────────────────
  Future<void> _saveNotification({
    required String userId,
    required String trackingId,
    required String category,
    required String type,
  }) async {
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .add({
      'userId':    userId,
      'title':     'Submission Received',
      'body':      'Your $type has been successfully submitted. Tracking ID: $trackingId.',
      'trackingId': trackingId,
      'type':      type,
      'isRead':    false,
      'createdAt': Timestamp.now(),
    });
  }

  // ── Get Complaints by Role (Real-time Stream) ─────────────────────────────────
  /// - User   → their own complaints only
  /// - Admin  → complaints for their department
  /// - Super Admin → all complaints
  Stream<List<ComplaintModel>> getComplaintsByRole(UserModel user) {
    final collection = _firestore.collection(AppConstants.complaintsCollection);

    Query query;

    if (user.isSuperAdmin) {
      query = collection.orderBy('createdAt', descending: true);
    } else if (user.isAdmin) {
      query = collection
          .where('department', isEqualTo: user.department)
          .orderBy('createdAt', descending: true);
    } else {
      query = collection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ComplaintModel.fromDocument(doc))
          .toList();
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

  // ── Update Status (Admin) ─────────────────────────────────────────────────────
  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    String? adminReply,
  }) async {
    try {
      final history = StatusHistory(
        status:    newStatus,
        changedAt: DateTime.now(),
        note:      adminReply,
      );

      await _firestore
          .collection(AppConstants.complaintsCollection)
          .doc(complaintId)
          .update({
        'status':     newStatus,
        'adminReply': adminReply,
        'repliedAt':  Timestamp.now(),
        'statusHistory': FieldValue.arrayUnion([history.toMap()]),
      });
      return true;
    } catch (e) {
      debugPrint('ComplaintService.updateComplaintStatus: $e');
      return false;
    }
  }

  // ── Analytics (Super Admin) ───────────────────────────────────────────────────
  Future<Map<String, int>> getAnalytics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.complaintsCollection)
          .get();

      final docs = snapshot.docs.map((d) => d.data()).toList();

      return {
        'total':      docs.length,
        'pending':    docs.where((d) => d['status'] == AppConstants.statusPending).length,
        'inProgress': docs.where((d) => d['status'] == AppConstants.statusInProgress).length,
        'resolved':   docs.where((d) => d['status'] == AppConstants.statusResolved).length,
        'rejected':   docs.where((d) => d['status'] == AppConstants.statusRejected).length,
      };
    } catch (e) {
      debugPrint('ComplaintService.getAnalytics: $e');
      return {};
    }
  }

  // ── Stream: Unread Notifications ──────────────────────────────────────────────
  Stream<int> unreadNotificationCount(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId',  isEqualTo: userId)
        .where('isRead',  isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
