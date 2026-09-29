// ─── User Model ────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String? studentId;      // Student / Registration No e.g. "2021-CS-101"
  final String email;
  final String role;           // 'student' | 'department_admin' | 'admin' | 'super_admin'
  final String? departmentId;   // Associated Department ID
  final String? departmentName; // Associated Department Name
  final String? phone;          // Optional Phone Number
  final DateTime createdAt;
  final String? photoUrl;
  final bool isActive;
  final String? fcmToken;       // Device FCM token

  const UserModel({
    required this.uid,
    required this.name,
    this.studentId,
    required this.email,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.phone,
    required this.createdAt,
    this.photoUrl,
    this.isActive = true,
    this.fcmToken,
  });

  // ── Backward Compatibility getter for department ────────────────────────────
  String? get department => departmentName ?? departmentId;

  // ── Role Helpers ─────────────────────────────────────────────────────────────
  bool get isStudent =>
      role == AppConstants.roleStudent ||
      role == AppConstants.roleUser ||
      role == 'user';

  bool get isUser => isStudent;

  bool get isDepartmentAdmin =>
      role == AppConstants.roleDepartmentAdmin ||
      (role == AppConstants.roleAdmin && departmentId != null && departmentId!.isNotEmpty);

  bool get isGeneralAdmin =>
      role == AppConstants.roleGeneralAdmin &&
      (departmentId == null || departmentId!.isEmpty);

  bool get isAdmin => isDepartmentAdmin || isGeneralAdmin || role == AppConstants.roleAdmin;

  bool get isSuperAdmin =>
      role == AppConstants.roleSuperAdmin ||
      role == AppConstants.roleSuperAdminAlias ||
      role == 'superAdmin';

  String get roleDisplay {
    if (isSuperAdmin) return 'Super Admin';
    if (isDepartmentAdmin) return 'Department Admin';
    if (isGeneralAdmin) return 'General Admin';
    return 'Student';
  }

  // ── Serialisation ────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid':            uid,
      'name':           name,
      'studentId':      studentId,
      'email':          email,
      'role':           role,
      'departmentId':   departmentId,
      'departmentName': departmentName,
      'department':     departmentName ?? departmentId, // Compatibility
      'phone':          phone,
      'createdAt':      Timestamp.fromDate(createdAt),
      'photoUrl':       photoUrl,
      'isActive':       isActive,
      'fcmToken':       fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawRole = (map['role'] as String?)?.trim() ?? AppConstants.roleStudent;
    final deptName = map['departmentName'] as String?;
    final legacyDept = map['department'] as String?;

    return UserModel(
      uid:            (id ?? map['uid'] ?? '') as String,
      name:           map['name']           as String? ?? '',
      studentId:      map['studentId']      as String?,
      email:          map['email']          as String? ?? '',
      role:           rawRole,
      departmentId:   map['departmentId']   as String? ?? (deptName == null ? legacyDept : null),
      departmentName: deptName ?? legacyDept,
      phone:          map['phone']          as String?,
      createdAt:      (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl:       map['photoUrl']       as String?,
      isActive:       map['isActive']       as bool?   ?? true,
      fcmToken:       map['fcmToken']       as String?,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  // ── copyWith ─────────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? uid,
    String? name,
    String? studentId,
    String? email,
    String? role,
    String? departmentId,
    String? departmentName,
    String? phone,
    DateTime? createdAt,
    String? photoUrl,
    bool? isActive,
    String? fcmToken,
  }) {
    return UserModel(
      uid:            uid            ?? this.uid,
      name:           name           ?? this.name,
      studentId:      studentId      ?? this.studentId,
      email:          email          ?? this.email,
      role:           role           ?? this.role,
      departmentId:   departmentId   ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      phone:          phone          ?? this.phone,
      createdAt:      createdAt      ?? this.createdAt,
      photoUrl:       photoUrl       ?? this.photoUrl,
      isActive:       isActive       ?? this.isActive,
      fcmToken:       fcmToken       ?? this.fcmToken,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email, role: $role, dept: $departmentName)';
}

