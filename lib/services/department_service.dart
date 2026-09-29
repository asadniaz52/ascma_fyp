// ─── Department Service ────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../utils/constants.dart';

class DepartmentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DepartmentService() {
    seedInitialDepartmentsIfEmpty();
  }

  // ── Seed Initial Departments ──────────────────────────────────────────────────
  Future<void> seedInitialDepartmentsIfEmpty() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.departmentsCollection)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final item in AppConstants.defaultDepartments) {
          final docRef = _firestore.collection(AppConstants.departmentsCollection).doc();
          final dept = DepartmentModel(
            departmentId: docRef.id,
            name:         item['name'] ?? '',
            code:         item['code'] ?? '',
            isActive:     true,
            createdAt:    DateTime.now(),
          );
          batch.set(docRef, dept.toMap());
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('DepartmentService.seedInitialDepartmentsIfEmpty: $e');
    }
  }

  // ── Stream Departments (Real-time) ───────────────────────────────────────────
  Stream<List<DepartmentModel>> getDepartmentsStream({bool onlyActive = true}) {
    Query query = _firestore.collection(AppConstants.departmentsCollection);
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DepartmentModel.fromDocument(doc))
          .toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  // ── Get Departments as Future List ───────────────────────────────────────────
  Future<List<DepartmentModel>> getDepartmentsList({bool onlyActive = true}) async {
    try {
      Query query = _firestore.collection(AppConstants.departmentsCollection);
      if (onlyActive) {
        query = query.where('isActive', isEqualTo: true);
      }
      final snapshot = await query.get();
      final list = snapshot.docs
          .map((doc) => DepartmentModel.fromDocument(doc))
          .toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    } catch (e) {
      debugPrint('DepartmentService.getDepartmentsList: $e');
      return [];
    }
  }

  // ── Add Department (Super Admin) ──────────────────────────────────────────────
  Future<String?> addDepartment({
    required String name,
    required String code,
    String? description,
  }) async {
    _setLoading(true);
    try {
      final docRef = _firestore.collection(AppConstants.departmentsCollection).doc();
      final dept = DepartmentModel(
        departmentId: docRef.id,
        name:         name.trim(),
        code:         code.trim().toUpperCase(),
        description:  description?.trim(),
        isActive:     true,
        createdAt:    DateTime.now(),
      );

      await docRef.set(dept.toMap());
      _setLoading(false);
      return null; // success
    } catch (e) {
      _setLoading(false);
      debugPrint('DepartmentService.addDepartment: $e');
      return 'Failed to add department. Please try again.';
    }
  }

  // ── Update Department (Super Admin) ──────────────────────────────────────────
  Future<bool> updateDepartment({
    required String departmentId,
    required String name,
    required String code,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': name.trim(),
        'code': code.trim().toUpperCase(),
      };
      if (description != null) updateData['description'] = description.trim();
      if (isActive != null) updateData['isActive'] = isActive;

      await _firestore
          .collection(AppConstants.departmentsCollection)
          .doc(departmentId)
          .update(updateData);
      return true;
    } catch (e) {
      debugPrint('DepartmentService.updateDepartment: $e');
      return false;
    }
  }

  // ── Toggle Status ─────────────────────────────────────────────────────────────
  Future<bool> toggleDepartmentStatus(String departmentId, bool currentStatus) async {
    try {
      await _firestore
          .collection(AppConstants.departmentsCollection)
          .doc(departmentId)
          .update({'isActive': !currentStatus});
      return true;
    } catch (e) {
      debugPrint('DepartmentService.toggleDepartmentStatus: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
