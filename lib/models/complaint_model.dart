// ─── Complaint Model ───────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ComplaintModel {
  final String complaintId;   // tracking ID e.g. ASC5847
  final String userId;        // 'ANONYMOUS' if isAnonymous == true
  final String? userName;     // null if anonymous
  final String title;
  final String description;
  final String category;
  final String type;          // 'complaint' | 'suggestion'
  final String status;        // Pending | In Progress | Resolved | Rejected
  final bool isAnonymous;
  final DateTime createdAt;
  final String department;
  final String? imageUrl;     // optional uploaded image
  final String? adminReply;
  final DateTime? repliedAt;
  final List<StatusHistory> statusHistory;

  const ComplaintModel({
    required this.complaintId,
    required this.userId,
    this.userName,
    required this.title,
    required this.description,
    required this.category,
    this.type = 'complaint',
    this.status = AppConstants.statusPending,
    this.isAnonymous = false,
    required this.createdAt,
    required this.department,
    this.imageUrl,
    this.adminReply,
    this.repliedAt,
    this.statusHistory = const [],
  });

  // ── Serialisation ────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'complaintId':   complaintId,
      'userId':        isAnonymous ? AppConstants.anonymousId : userId,
      'userName':      isAnonymous ? null : userName,
      'title':         title,
      'description':   description,
      'category':      category,
      'type':          type,
      'status':        status,
      'isAnonymous':   isAnonymous,
      'createdAt':     Timestamp.fromDate(createdAt),
      'department':    department,
      'imageUrl':      imageUrl,
      'adminReply':    adminReply,
      'repliedAt':     repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    final historyRaw = map['statusHistory'] as List<dynamic>? ?? [];
    return ComplaintModel(
      complaintId:   map['complaintId']   as String? ?? '',
      userId:        map['userId']        as String? ?? AppConstants.anonymousId,
      userName:      map['userName']      as String?,
      title:         map['title']         as String? ?? '',
      description:   map['description']   as String? ?? '',
      category:      map['category']      as String? ?? '',
      type:          map['type']          as String? ?? 'complaint',
      status:        map['status']        as String? ?? AppConstants.statusPending,
      isAnonymous:   map['isAnonymous']   as bool?   ?? false,
      createdAt:     (map['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      department:    map['department']    as String? ?? '',
      imageUrl:      map['imageUrl']      as String?,
      adminReply:    map['adminReply']    as String?,
      repliedAt:     (map['repliedAt']    as Timestamp?)?.toDate(),
      statusHistory: historyRaw.map((e) => StatusHistory.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  factory ComplaintModel.fromDocument(DocumentSnapshot doc) {
    return ComplaintModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ── copyWith ─────────────────────────────────────────────────────────────────
  ComplaintModel copyWith({
    String? complaintId,
    String? userId,
    String? userName,
    String? title,
    String? description,
    String? category,
    String? type,
    String? status,
    bool? isAnonymous,
    DateTime? createdAt,
    String? department,
    String? imageUrl,
    String? adminReply,
    DateTime? repliedAt,
    List<StatusHistory>? statusHistory,
  }) {
    return ComplaintModel(
      complaintId:   complaintId   ?? this.complaintId,
      userId:        userId        ?? this.userId,
      userName:      userName      ?? this.userName,
      title:         title         ?? this.title,
      description:   description   ?? this.description,
      category:      category      ?? this.category,
      type:          type          ?? this.type,
      status:        status        ?? this.status,
      isAnonymous:   isAnonymous   ?? this.isAnonymous,
      createdAt:     createdAt     ?? this.createdAt,
      department:    department    ?? this.department,
      imageUrl:      imageUrl      ?? this.imageUrl,
      adminReply:    adminReply    ?? this.adminReply,
      repliedAt:     repliedAt     ?? this.repliedAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  @override
  String toString() =>
      'ComplaintModel(id: $complaintId, category: $category, status: $status)';
}

// ─── Status History Sub-Model ──────────────────────────────────────────────────
class StatusHistory {
  final String status;
  final DateTime changedAt;
  final String? note;

  const StatusHistory({
    required this.status,
    required this.changedAt,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'status':    status,
    'changedAt': Timestamp.fromDate(changedAt),
    'note':      note,
  };

  factory StatusHistory.fromMap(Map<String, dynamic> map) => StatusHistory(
    status:    map['status']    as String? ?? '',
    changedAt: (map['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    note:      map['note']      as String?,
  );
}
