// ─── Auth Service ──────────────────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth         = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User?      _firebaseUser;
  UserModel? _currentUser;
  bool       _isLoading = false;

  // ── Getters ───────────────────────────────────────────────────────────────────
  User?      get firebaseUser  => _firebaseUser;
  UserModel? get currentUser   => _currentUser;
  bool       get isLoading     => _isLoading;
  bool       get isLoggedIn    => _firebaseUser != null;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ── Auth State ────────────────────────────────────────────────────────────────
  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _fetchUserProfile(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        _currentUser = UserModel.fromDocument(doc);
      }
    } catch (e) {
      debugPrint('AuthService._fetchUserProfile: $e');
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────────
  /// Creates a Firebase Auth account and saves user profile in Firestore.
  /// Default role is 'user'.
  Future<String?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );

      await credential.user?.updateDisplayName(name.trim());

      final user = UserModel(
        uid:       credential.user!.uid,
        name:      name.trim(),
        email:     email.trim(),
        role:      AppConstants.roleUser,
        createdAt: DateTime.now(),
        isActive:  true,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      _currentUser = user;
      _setLoading(false);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _mapAuthError(e.code);
    } catch (e) {
      _setLoading(false);
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Authenticates user and fetches role from Firestore.
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password.trim(),
      );

      await _fetchUserProfile(credential.user!.uid);
      _setLoading(false);
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _mapAuthError(e.code);
    } catch (e) {
      _setLoading(false);
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────────
  Future<String?> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _mapAuthError(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Failed to send reset email. Please try again.';
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser   = null;
    _firebaseUser  = null;
    notifyListeners();
  }

  // ── Create Admin (Super Admin only) ───────────────────────────────────────────
  Future<String?> createAdminAccount({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    _setLoading(true);
    try {
      // Create secondary auth instance to avoid signing out current super admin
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
      final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
            email:    email.trim(),
            password: password.trim(),
          );
      await secondaryApp.delete();

      final admin = UserModel(
        uid:        credential.user!.uid,
        name:       name.trim(),
        email:      email.trim(),
        role:       AppConstants.roleAdmin,
        department: department,
        createdAt:  DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(admin.uid)
          .set(admin.toMap());

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _mapAuthError(e.code);
    } catch (e) {
      _setLoading(false);
      return 'Failed to create admin account.';
    }
  }

  // ── Stream: Real-time user profile ───────────────────────────────────────────
  Stream<UserModel?> userStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDocument(doc) : null);
  }

  // ── Stream: All Users (Admin/Super Admin) ────────────────────────────────────
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ── Stream: All Admin Users (Super Admin) ───────────────────────────────────
  Stream<List<UserModel>> getAdmins() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleAdmin)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ── Toggle User Active Status ────────────────────────────────────────────────
  Future<bool> toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isActive': !currentStatus});
      return true;
    } catch (e) {
      debugPrint('AuthService.toggleUserStatus: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
