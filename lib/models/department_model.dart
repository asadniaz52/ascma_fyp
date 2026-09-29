// ─── Department Model ────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String departmentId;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  const DepartmentModel({
    required this.departmentId,
    required this.name,
    required this.code,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'name':         name,
      'code':         code,
      'description':  description,
      'isActive':     isActive,
      'createdAt':    Timestamp.fromDate(createdAt),
    };
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DepartmentModel(
      departmentId: (id ?? map['departmentId'] ?? '') as String,
      name:         (map['name'] as String?)?.trim() ?? '',
      code:         (map['code'] as String?)?.trim().toUpperCase() ?? '',
      description:  map['description'] as String?,
      isActive:     (map['isActive'] as bool?) ?? true,
      createdAt:    (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory DepartmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DepartmentModel.fromMap(data, id: doc.id);
  }

  DepartmentModel copyWith({
    String? departmentId,
    String? name,
    String? code,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DepartmentModel(
      departmentId: departmentId ?? this.departmentId,
      name:         name ?? this.name,
      code:         code ?? this.code,
      description:  description ?? this.description,
      isActive:     isActive ?? this.isActive,
      createdAt:    createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentModel &&
          runtimeType == other.runtimeType &&
          departmentId == other.departmentId;

  @override
  int get hashCode => departmentId.hashCode;

  @override
  String toString() => 'DepartmentModel(id: $departmentId, name: $name, code: $code)';
}
