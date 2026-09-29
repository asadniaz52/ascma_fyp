// ─── App Constants ─────────────────────────────────────────────────────────────
class AppConstants {
  // App Info
  static const String appName        = 'ASCMA';
  static const String appFullName    = 'Anonymous Suggestion & Complaint Management Application';
  static const String appVersion     = '1.1.0';
  static const String appYear        = '2025';
  static const String copyright      = '© 2025 Anonymous Feedback System\nAll Rights Reserved';

  // Storage Keys
  static const String keyHasSeenOnboarding = 'hasSeenOnboarding';

  // User Roles
  static const String roleStudent         = 'student';
  static const String roleUser            = 'user';           // Legacy alias for student
  static const String roleDepartmentAdmin = 'department_admin';
  static const String roleGeneralAdmin    = 'admin';
  static const String roleAdmin           = 'admin';          // Legacy alias
  static const String roleSuperAdmin      = 'super_admin';
  static const String roleSuperAdminAlias = 'superAdmin';     // Legacy alias
  static const String anonymousId         = 'ANONYMOUS';

  // Complaint Statuses
  static const String statusPending    = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved   = 'Resolved';
  static const String statusReferred   = 'Referred';
  static const String statusRejected   = 'Rejected';
  static const String statusClosed     = 'Closed';

  // Priorities
  static const String priorityNormal = 'Normal';
  static const String priorityMedium = 'Medium';
  static const String priorityHigh   = 'High';
  static const String priorityUrgent = 'Urgent';

  static const List<String> priorities = [
    priorityNormal,
    priorityMedium,
    priorityHigh,
    priorityUrgent,
  ];

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Academic & Teaching',
    'Examination & Grading',
    'Lab & Computer Equipment',
    'Infrastructure & Facilities',
    'Harassment & Conduct',
    'Administration & Delays',
    'Library & Resources',
    'Fee & Financial',
    'Hostel & Transport',
    'Others',
  ];

  // Suggestion Categories
  static const List<String> suggestionCategories = [
    'Academic Improvement',
    'Campus Facilities',
    'Lab Enhancement',
    'Digital Services & App',
    'Sports & Extracurricular',
    'Policy & Procedures',
    'Others',
  ];

  // Default University Departments Seed
  static const List<Map<String, String>> defaultDepartments = [
    {'name': 'Computer Science',       'code': 'CS'},
    {'name': 'Software Engineering',   'code': 'SE'},
    {'name': 'Electrical Engineering', 'code': 'EE'},
    {'name': 'Management Sciences',    'code': 'MS'},
    {'name': 'English Department',     'code': 'ENG'},
    {'name': 'Mathematics Department', 'code': 'MATH'},
    {'name': 'Physics Department',     'code': 'PHY'},
    {'name': 'Chemistry Department',   'code': 'CHEM'},
    {'name': 'Academic Affairs',       'code': 'ACAD'},
    {'name': 'Student Affairs',        'code': 'SA'},
    {'name': 'General Administration', 'code': 'ADMIN'},
    {'name': 'Finance & Accounts',     'code': 'FIN'},
  ];

  // Firestore Collections
  static const String usersCollection         = 'users';
  static const String departmentsCollection   = 'departments';
  static const String complaintsCollection    = 'complaints';
  static const String notificationsCollection = 'notifications';

  // Tracking ID Prefix
  static const String trackingPrefix = 'ASC';
}

