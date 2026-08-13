// ─── User Model ────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' | 'admin' | 'superAdmin'
  final String? department; // only for admins
  final DateTime createdAt;
  final String? photoUrl;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    required this.createdAt,
    this.photoUrl,
    this.isActive = true,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────────
  bool get isUser       => role == AppConstants.roleUser;
  bool get isAdmin      => role == AppConstants.roleAdmin;
  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;

  // ── Serialisation ────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid':        uid,
      'name':       name,
      'email':      email,
      'role':       role,
      'department': department,
      'createdAt':  Timestamp.fromDate(createdAt),
      'photoUrl':   photoUrl,
      'isActive':   isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:        map['uid']        as String? ?? '',
      name:       map['name']       as String? ?? '',
      email:      map['email']      as String? ?? '',
      role:       map['role']       as String? ?? AppConstants.roleUser,
      department: map['department'] as String?,
      createdAt:  (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl:   map['photoUrl']   as String?,
      isActive:   map['isActive']   as bool?   ?? true,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ── copyWith ─────────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? department,
    DateTime? createdAt,
    String? photoUrl,
    bool? isActive,
  }) {
    return UserModel(
      uid:        uid        ?? this.uid,
      name:       name       ?? this.name,
      email:      email      ?? this.email,
      role:       role       ?? this.role,
      department: department ?? this.department,
      createdAt:  createdAt  ?? this.createdAt,
      photoUrl:   photoUrl   ?? this.photoUrl,
      isActive:   isActive   ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, email: $email, role: $role)';
}
