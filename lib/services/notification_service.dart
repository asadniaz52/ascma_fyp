// ─── Notification Service ───────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? trackingId;
  final String? type;
  final String? departmentId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.trackingId,
    this.type,
    this.departmentId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId':       userId,
    'title':        title,
    'body':         body,
    'trackingId':   trackingId,
    'type':         type,
    'departmentId': departmentId,
    'isRead':       isRead,
    'createdAt':    Timestamp.fromDate(createdAt),
  };

  factory NotificationItem.fromDocument(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationItem(
      id:           doc.id,
      userId:       map['userId'] as String? ?? '',
      title:        map['title'] as String? ?? '',
      body:         map['body'] as String? ?? '',
      trackingId:   map['trackingId'] as String?,
      type:         map['type'] as String?,
      departmentId: map['departmentId'] as String?,
      isRead:       map['isRead'] as bool? ?? false,
      createdAt:    (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Send Notification to Specific User ───────────────────────────────────────
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? trackingId,
    String? type,
    String? departmentId,
  }) async {
    try {
      await _firestore.collection(AppConstants.notificationsCollection).add({
        'userId':       userId,
        'title':        title,
        'body':         body,
        'trackingId':   trackingId,
        'type':         type,
        'departmentId': departmentId,
        'isRead':       false,
        'createdAt':    Timestamp.now(),
      });
    } catch (e) {
      debugPrint('NotificationService.sendNotification error: $e');
    }
  }

  // ── Notify Department Admins of New Complaint ─────────────────────────────────
  Future<void> notifyDepartmentAdmins({
    required String departmentId,
    required String departmentName,
    required String trackingId,
    required String type,
    required String category,
  }) async {
    try {
      // Find all active admins for this department
      final adminsSnap = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', whereIn: [AppConstants.roleDepartmentAdmin, AppConstants.roleAdmin])
          .where('isActive', isEqualTo: true)
          .get();

      final targetAdmins = adminsSnap.docs.where((doc) {
        final data = doc.data();
        final dId = data['departmentId'] ?? data['department'];
        final dName = data['departmentName'] ?? data['department'];
        return dId == departmentId || dName == departmentName;
      }).toList();

      for (final adminDoc in targetAdmins) {
        await sendNotification(
          userId:       adminDoc.id,
          title:        'New $type: $category',
          body:         'A new $type ($trackingId) has been submitted for $departmentName.',
          trackingId:   trackingId,
          type:         type,
          departmentId: departmentId,
        );
      }
    } catch (e) {
      debugPrint('NotificationService.notifyDepartmentAdmins error: $e');
    }
  }

  // ── Notify Super Admins when Complaint is Referred ───────────────────────────
  Future<void> notifySuperAdminsOnReferral({
    required String trackingId,
    required String departmentName,
    required String referringAdminName,
    required String reason,
  }) async {
    try {
      final superAdminsSnap = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', whereIn: [AppConstants.roleSuperAdmin, AppConstants.roleSuperAdminAlias])
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in superAdminsSnap.docs) {
        await sendNotification(
          userId:     doc.id,
          title:      'Referred Complaint: $trackingId',
          body:       '$referringAdminName ($departmentName) referred a complaint to University Administration. Reason: $reason',
          trackingId: trackingId,
          type:       'referral',
        );
      }
    } catch (e) {
      debugPrint('NotificationService.notifySuperAdminsOnReferral error: $e');
    }
  }

  // ── Notify Student on Status Update ──────────────────────────────────────────
  Future<void> notifyStudentStatusUpdate({
    required String studentId,
    required String trackingId,
    required String newStatus,
    String? adminReply,
  }) async {
    if (studentId.isEmpty || studentId == AppConstants.anonymousId) return;

    final notePreview = (adminReply != null && adminReply.isNotEmpty)
        ? '\nOfficial Reply: $adminReply'
        : '';

    await sendNotification(
      userId:     studentId,
      title:      'Status Updated: $newStatus',
      body:       'Your submission ($trackingId) status has changed to "$newStatus".$notePreview',
      trackingId: trackingId,
      type:       'status_update',
    );
  }

  // ── Stream Notifications for User/Admin ──────────────────────────────────────
  Stream<List<NotificationItem>> getUserNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => NotificationItem.fromDocument(doc))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  // ── Stream Unread Count ───────────────────────────────────────────────────────
  Stream<int> unreadCount(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ── Mark Notification as Read ────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('NotificationService.markAsRead error: $e');
    }
  }

  // ── Mark All Read ────────────────────────────────────────────────────────────
  Future<void> markAllAsRead(String userId) async {
    try {
      final snap = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('NotificationService.markAllAsRead error: $e');
    }
  }
}
