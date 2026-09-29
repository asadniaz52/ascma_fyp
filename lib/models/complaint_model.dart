// ─── Complaint Model ───────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ComplaintModel {
  final String complaintId;           // tracking ID e.g. ASC5847
  final String userId;                // 'ANONYMOUS' if isAnonymous == true
  final String? userName;             // null if anonymous
  final String? studentRegNo;         // Student / Reg No (null if anonymous)
  final String title;
  final String description;
  final String category;
  final String type;                  // 'complaint' | 'suggestion'
  final String status;                // Pending | In Progress | Resolved | Referred | Rejected | Closed
  final String priority;              // Normal | Medium | High | Urgent
  final bool isAnonymous;
  final String departmentId;          // Target Department ID
  final String departmentName;        // Target Department Name
  final String? assignedAdminId;      // Specific admin assigned
  final String? assignedAdminName;
  final String? imageUrl;             // optional uploaded image
  final String? adminReply;           // official admin response
  final DateTime? repliedAt;
  final bool referredToSuperAdmin;    // true if referred to University / Super Admin
  final DateTime? referredAt;
  final String? referringAdminId;
  final String? referringAdminName;
  final String? referralReason;       // mandatory reason when referred
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistory> statusHistory;

  const ComplaintModel({
    required this.complaintId,
    required this.userId,
    this.userName,
    this.studentRegNo,
    required this.title,
    required this.description,
    required this.category,
    this.type = 'complaint',
    this.status = AppConstants.statusPending,
    this.priority = AppConstants.priorityNormal,
    this.isAnonymous = false,
    required this.departmentId,
    required this.departmentName,
    this.assignedAdminId,
    this.assignedAdminName,
    this.imageUrl,
    this.adminReply,
    this.repliedAt,
    this.referredToSuperAdmin = false,
    this.referredAt,
    this.referringAdminId,
    this.referringAdminName,
    this.referralReason,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.statusHistory = const [],
  });

  // ── Backward compatibility getter for department string ──────────────────────
  String get department => departmentName.isNotEmpty ? departmentName : departmentId;

  // ── Serialisation ────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'complaintId':           complaintId,
      'userId':                isAnonymous ? AppConstants.anonymousId : userId,
      'studentId':             isAnonymous ? AppConstants.anonymousId : userId,
      'userName':              isAnonymous ? null : userName,
      'studentName':           isAnonymous ? null : userName,
      'studentRegNo':          isAnonymous ? null : studentRegNo,
      'title':                 title,
      'description':           description,
      'category':              category,
      'type':                  type,
      'status':                status,
      'priority':              priority,
      'isAnonymous':           isAnonymous,
      'departmentId':          departmentId,
      'departmentName':        departmentName,
      'department':            departmentName, // Compatibility
      'assignedAdminId':       assignedAdminId,
      'assignedAdminName':     assignedAdminName,
      'imageUrl':              imageUrl,
      'adminReply':            adminReply,
      'repliedAt':             repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
      'referredToSuperAdmin':  referredToSuperAdmin,
      'referredAt':            referredAt != null ? Timestamp.fromDate(referredAt!) : null,
      'referringAdminId':      referringAdminId,
      'referringAdminName':    referringAdminName,
      'referralReason':        referralReason,
      'resolvedAt':            resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'createdAt':             Timestamp.fromDate(createdAt),
      'updatedAt':             Timestamp.fromDate(updatedAt),
      'statusHistory':         statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final historyRaw = map['statusHistory'] as List<dynamic>? ?? [];
    final deptName = (map['departmentName'] as String?)?.trim() ?? (map['department'] as String?)?.trim() ?? '';
    final deptId = (map['departmentId'] as String?)?.trim() ?? deptName;
    final uName = (map['userName'] as String?) ?? (map['studentName'] as String?);
    final uId = (map['userId'] as String?) ?? (map['studentId'] as String?) ?? AppConstants.anonymousId;

    return ComplaintModel(
      complaintId:          (id ?? map['complaintId'] ?? '') as String,
      userId:               uId,
      userName:             uName,
      studentRegNo:         map['studentRegNo'] as String?,
      title:                map['title']         as String? ?? '',
      description:          map['description']   as String? ?? '',
      category:             map['category']      as String? ?? '',
      type:                 map['type']          as String? ?? 'complaint',
      status:               map['status']        as String? ?? AppConstants.statusPending,
      priority:             map['priority']      as String? ?? AppConstants.priorityNormal,
      isAnonymous:          map['isAnonymous']   as bool?   ?? false,
      departmentId:         deptId,
      departmentName:       deptName.isNotEmpty ? deptName : deptId,
      assignedAdminId:      map['assignedAdminId']   as String?,
      assignedAdminName:    map['assignedAdminName'] as String?,
      imageUrl:             map['imageUrl']          as String?,
      adminReply:           map['adminReply']        as String?,
      repliedAt:            (map['repliedAt']    as Timestamp?)?.toDate(),
      referredToSuperAdmin: map['referredToSuperAdmin'] as bool? ?? (map['status'] == AppConstants.statusReferred),
      referredAt:           (map['referredAt']   as Timestamp?)?.toDate(),
      referringAdminId:     map['referringAdminId']   as String?,
      referringAdminName:   map['referringAdminName'] as String?,
      referralReason:       map['referralReason']     as String?,
      resolvedAt:           (map['resolvedAt']   as Timestamp?)?.toDate(),
      createdAt:            (map['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:            (map['updatedAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      statusHistory:        historyRaw.map((e) => StatusHistory.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  factory ComplaintModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ComplaintModel.fromMap(data, id: doc.id);
  }

  // ── copyWith ─────────────────────────────────────────────────────────────────
  ComplaintModel copyWith({
    String? complaintId,
    String? userId,
    String? userName,
    String? studentRegNo,
    String? title,
    String? description,
    String? category,
    String? type,
    String? status,
    String? priority,
    bool? isAnonymous,
    String? departmentId,
    String? departmentName,
    String? assignedAdminId,
    String? assignedAdminName,
    String? imageUrl,
    String? adminReply,
    DateTime? repliedAt,
    bool? referredToSuperAdmin,
    DateTime? referredAt,
    String? referringAdminId,
    String? referringAdminName,
    String? referralReason,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StatusHistory>? statusHistory,
  }) {
    return ComplaintModel(
      complaintId:          complaintId          ?? this.complaintId,
      userId:               userId               ?? this.userId,
      userName:             userName             ?? this.userName,
      studentRegNo:         studentRegNo         ?? this.studentRegNo,
      title:                title                ?? this.title,
      description:          description          ?? this.description,
      category:             category             ?? this.category,
      type:                 type                 ?? this.type,
      status:               status               ?? this.status,
      priority:             priority             ?? this.priority,
      isAnonymous:          isAnonymous          ?? this.isAnonymous,
      departmentId:         departmentId         ?? this.departmentId,
      departmentName:       departmentName       ?? this.departmentName,
      assignedAdminId:      assignedAdminId      ?? this.assignedAdminId,
      assignedAdminName:    assignedAdminName    ?? this.assignedAdminName,
      imageUrl:             imageUrl             ?? this.imageUrl,
      adminReply:           adminReply           ?? this.adminReply,
      repliedAt:            repliedAt            ?? this.repliedAt,
      referredToSuperAdmin: referredToSuperAdmin ?? this.referredToSuperAdmin,
      referredAt:           referredAt           ?? this.referredAt,
      referringAdminId:     referringAdminId     ?? this.referringAdminId,
      referringAdminName:   referringAdminName   ?? this.referringAdminName,
      referralReason:       referralReason       ?? this.referralReason,
      resolvedAt:           resolvedAt           ?? this.resolvedAt,
      createdAt:            createdAt            ?? this.createdAt,
      updatedAt:            updatedAt            ?? this.updatedAt,
      statusHistory:        statusHistory        ?? this.statusHistory,
    );
  }

  @override
  String toString() =>
      'ComplaintModel(id: $complaintId, dept: $departmentName, status: $status, referred: $referredToSuperAdmin)';
}

// ─── Status History Sub-Model ──────────────────────────────────────────────────
class StatusHistory {
  final String status;
  final String? action;
  final String? performedBy;
  final String? performedByRole;
  final DateTime changedAt;
  final String? note;

  const StatusHistory({
    required this.status,
    this.action,
    this.performedBy,
    this.performedByRole,
    required this.changedAt,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'status':          status,
    'action':          action,
    'performedBy':     performedBy,
    'performedByRole': performedByRole,
    'changedAt':       Timestamp.fromDate(changedAt),
    'note':            note,
  };

  factory StatusHistory.fromMap(Map<String, dynamic> map) => StatusHistory(
    status:          map['status']          as String? ?? '',
    action:          map['action']          as String?,
    performedBy:     map['performedBy']     as String?,
    performedByRole: map['performedByRole'] as String?,
    changedAt:       (map['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    note:            map['note']            as String?,
  );
}

