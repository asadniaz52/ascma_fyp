// ─── App Constants ─────────────────────────────────────────────────────────────
class AppConstants {
  // App Info
  static const String appName        = 'ASCMA';
  static const String appFullName    = 'Anonymous Suggestion & Complaint Management Application';
  static const String appVersion     = '1.0.0';
  static const String appYear        = '2025';
  static const String copyright      = '© 2025 Anonymous Feedback System\nAll Rights Reserved';

  // User Roles
  static const String roleUser       = 'user';
  static const String roleAdmin      = 'admin';
  static const String roleSuperAdmin = 'superAdmin';
  static const String anonymousId   = 'ANONYMOUS';

  // Complaint Statuses
  static const String statusPending    = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved   = 'Resolved';
  static const String statusRejected   = 'Rejected';

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Corruption',
    'Harassment',
    'Misuse of Authority',
    'Service Delay',
    'Fraud',
    'Others',
  ];

  // Suggestion Categories
  static const List<String> suggestionCategories = [
    'Service Improvement',
    'System Enhancement',
    'Policy Suggestion',
    'Staff Training',
    'Facility Improvement',
    'Others',
  ];

  // Departments
  static const List<String> departments = [
    'Academic Affairs',
    'Administration',
    'Finance',
    'HR Department',
    'IT Department',
    'Infrastructure',
    'Management',
    'Student Affairs',
  ];

  // Firestore Collections
  static const String usersCollection      = 'users';
  static const String complaintsCollection = 'complaints';
  static const String notificationsCollection = 'notifications';

  // Tracking ID Prefix
  static const String trackingPrefix = 'ASC';
}
