// ─── Admin Dashboard Screen ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../auth/welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentViewIndex = 0; // 0: Dashboard, 1: Complaints, 2: Suggestions, 3: Users, 4: Admins, 5: Reports, 6: Notifications
  int _bottomNavIndex = 0;
  String _statusFilter = '';

  void _onBottomNavTap(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) _currentViewIndex = 1; // Complaints
      if (index == 1) _currentViewIndex = 2; // Suggestions
      if (index == 2) _currentViewIndex = 3; // Users
    });
  }

  void _switchView(int index) {
    setState(() {
      _currentViewIndex = index;
      if (index == 1) _bottomNavIndex = 0;
      if (index == 2) _bottomNavIndex = 1;
      if (index == 3) _bottomNavIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AscmaAppBar(
        title: _getViewTitle(),
        showMenu: true,
      ),
      drawer: _buildDrawer(context, user),
      body: _buildCurrentView(user),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getViewTitle() {
    switch (_currentViewIndex) {
      case 0: return 'Admin Dashboard';
      case 1: return 'Manage Complaints';
      case 2: return 'Review Suggestions';
      case 3: return 'User Management';
      case 4: return 'Admin Management';
      case 5: return 'Reports & Analytics';
      case 6: return 'System Notifications';
      default: return 'Admin Panel';
    }
  }

  Widget _buildCurrentView(UserModel user) {
    switch (_currentViewIndex) {
      case 0: return _buildDashboardOverview(user);
      case 1: return _buildComplaintsView(user, type: 'complaint');
      case 2: return _buildComplaintsView(user, type: 'suggestion');
      case 3: return _buildUserManagementView();
      case 4: return _buildAdminManagementView();
      case 5: return _buildReportsView(user);
      case 6: return _buildNotificationsLogView(user);
      default: return _buildDashboardOverview(user);
    }
  }

  // ── 0. DASHBOARD OVERVIEW ──────────────────────────────────────────────────
  Widget _buildDashboardOverview(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header
          Text(
            'Hello, ${user.name} 👋',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Department: ${user.department ?? "General Administration"}',
            style: GoogleFonts.poppins(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Real-time Stat Cards Grid
          StreamBuilder<Map<String, int>>(
            stream: context.read<ComplaintService>().getRealtimeAnalytics(user),
            builder: (context, snapAnalytics) {
              final stats = snapAnalytics.data ?? {};
              return StreamBuilder<List<UserModel>>(
                stream: context.read<AuthService>().getAllUsers(),
                builder: (context, snapUsers) {
                  final totalUsersCount = (snapUsers.data ?? []).length;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'Pending\nComplaints',
                              value: '${stats['pendingComplaints'] ?? 0}',
                              color: const Color(0xFFEF5350),
                              icon: Icons.campaign_rounded,
                              onTap: () => _switchView(1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'Pending\nSuggestions',
                              value: '${stats['pendingSuggestions'] ?? 0}',
                              color: const Color(0xFF26A69A),
                              icon: Icons.lightbulb_rounded,
                              onTap: () => _switchView(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'Total\nUsers',
                              value: '$totalUsersCount',
                              color: const Color(0xFF7E57C2),
                              icon: Icons.person_rounded,
                              onTap: () => _switchView(3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'Resolved\nCases',
                              value: '${stats['resolved'] ?? 0}',
                              color: const Color(0xFF66BB6A),
                              icon: Icons.check_circle_outline_rounded,
                              onTap: () => _switchView(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent Submissions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Submissions',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () => _switchView(1),
                child: Text(
                  'View All >',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Real Submissions Stream
          StreamBuilder<List<ComplaintModel>>(
            stream: context.read<ComplaintService>().getComplaintsByRole(user),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ));
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No submissions received yet.',
                        style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
                  ),
                );
              }
              final recent = items.take(4).toList();
              return Column(
                children: recent.map((item) => _buildSubmissionTile(context, item)).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // Recent Users Activity Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered Users',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () => _switchView(3),
                child: Text(
                  'View All >',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Real Users Stream
          StreamBuilder<List<UserModel>>(
            stream: context.read<AuthService>().getAllUsers(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ));
              }
              final users = snap.data ?? [];
              if (users.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No registered users yet.',
                        style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
                  ),
                );
              }
              final recentUsers = users.take(3).toList();
              return Column(
                children: recentUsers.map((u) => _buildUserTile(context, u)).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── 1 & 2. COMPLAINTS / SUGGESTIONS VIEW ────────────────────────────────────
  Widget _buildComplaintsView(UserModel user, {required String type}) {
    final isComplaint = type == 'complaint';
    return Column(
      children: [
        // Status Filter Chips Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', ''),
                _buildFilterChip('Pending', AppConstants.statusPending),
                _buildFilterChip('In Progress', AppConstants.statusInProgress),
                _buildFilterChip('Resolved', AppConstants.statusResolved),
                _buildFilterChip('Rejected', AppConstants.statusRejected),
              ],
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<List<ComplaintModel>>(
            stream: context.read<ComplaintService>().getComplaintsByRole(
                  user,
                  typeFilter: type,
                  statusFilter: _statusFilter,
                ),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }

              final items = snap.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isComplaint ? Icons.campaign_outlined : Icons.lightbulb_outline,
                        size: 64,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No ${isComplaint ? "complaints" : "suggestions"} found',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildSubmissionTile(context, items[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _statusFilter = value),
        selectedColor: AppColors.primaryBlue,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  // ── 3. USER MANAGEMENT VIEW ────────────────────────────────────────────────
  Widget _buildUserManagementView() {
    return StreamBuilder<List<UserModel>>(
      stream: context.read<AuthService>().getAllUsers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text('No registered users found.',
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: u.isAdmin ? AppColors.primaryBlue : Colors.grey.shade300,
                  child: Icon(
                    u.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: u.isAdmin ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                title: Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${u.email}  •  Role: ${u.role.toUpperCase()}',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                trailing: Switch(
                  value: u.isActive,
                  activeColor: AppColors.greenCard,
                  onChanged: (val) async {
                    await context.read<AuthService>().toggleUserStatus(u.uid, u.isActive);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 4. ADMIN MANAGEMENT VIEW ────────────────────────────────────────────────
  Widget _buildAdminManagementView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existing Department Admins',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<UserModel>>(
            stream: context.read<AuthService>().getAdmins(),
            builder: (context, snap) {
              final admins = snap.data ?? [];
              if (admins.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('No department admins created yet.',
                        style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12)),
                  ),
                );
              }
              return Column(
                children: admins.map((admin) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryBlue),
                    title: Text(admin.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    subtitle: Text('${admin.email}\nDepartment: ${admin.department ?? "N/A"}',
                        style: GoogleFonts.poppins(fontSize: 11)),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 5. REPORTS & ANALYTICS VIEW ─────────────────────────────────────────────
  Widget _buildReportsView(UserModel user) {
    return StreamBuilder<Map<String, int>>(
      stream: context.read<ComplaintService>().getRealtimeAnalytics(user),
      builder: (context, snap) {
        final data = snap.data ?? {};
        final total = data['total'] ?? 0;
        final resolved = data['resolved'] ?? 0;
        final pending = data['pending'] ?? 0;
        final inProgress = data['inProgress'] ?? 0;
        final rejected = data['rejected'] ?? 0;

        final resolutionRate = total > 0 ? ((resolved / total) * 100).toStringAsFixed(1) : '0';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resolution Efficiency', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('$resolutionRate%',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
  'Total Submissions Received: $total',
  style: GoogleFonts.poppins(
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 12,
  ),
),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Status Breakdown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              _buildReportCard('Pending Review', '$pending', const Color(0xFFEF5350), Icons.hourglass_top),
              _buildReportCard('Under Process', '$inProgress', AppColors.primaryBlue, Icons.sync),
              _buildReportCard('Successfully Resolved', '$resolved', const Color(0xFF66BB6A), Icons.check_circle_outline),
              _buildReportCard('Rejected', '$rejected', Colors.grey.shade700, Icons.cancel_outlined),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(String title, String count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          Text(count, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
        ],
      ),
    );
  }

  // ── 6. NOTIFICATIONS LOG VIEW ────────────────────────────────────────────────
  Widget _buildNotificationsLogView(UserModel user) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: context.read<ComplaintService>().getComplaintsByRole(user),
      builder: (context, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(child: Text('No system activity logged.', style: GoogleFonts.poppins(color: AppColors.textGrey)));
        }
        final fmt = DateFormat('dd MMM yyyy, hh:mm a');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue),
                title: Text('New ${item.type.toUpperCase()}: ${item.category}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('ID: ${item.complaintId}  •  ${fmt.format(item.createdAt)}', style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () => _showSubmissionDetailModal(context, item),
              ),
            );
          },
        );
      },
    );
  }

  // ── REUSABLE SUBMISSION TILE ─────────────────────────────────────────────────
  Widget _buildSubmissionTile(BuildContext context, ComplaintModel item) {
    final bool isComplaint = item.type.toLowerCase() == 'complaint';
    final fmt = DateFormat('dd MMM, hh:mm a');

    return GestureDetector(
      onTap: () => _showSubmissionDetailModal(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isComplaint ? const Color(0xFFEF5350) : const Color(0xFF26A69A)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isComplaint ? Icons.campaign_rounded : Icons.lightbulb_rounded,
                color: isComplaint ? const Color(0xFFEF5350) : const Color(0xFF26A69A),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.category,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: item.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        item.isAnonymous ? Icons.person_off_outlined : Icons.person_outline_rounded,
                        size: 13,
                        color: item.isAnonymous ? Colors.deepOrange : AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.isAnonymous || item.userName == null || item.userName!.trim().isEmpty
                              ? 'Student: Anonymous'
                              : 'Student: ${item.userName}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.isAnonymous ? Colors.deepOrange : AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('ID: ${item.complaintId}  •  Dept: ${item.department}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(fmt.format(item.createdAt), style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(u.email, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: u.isActive ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              u.isActive ? 'Active' : 'Disabled',
              style: GoogleFonts.poppins(fontSize: 10, color: u.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── SUBMISSION DETAIL & UPDATE MODAL ───────────────────────────────────────
  void _showSubmissionDetailModal(BuildContext context, ComplaintModel item) {
    String selectedStatus = item.status;
    final replyCtrl = TextEditingController(text: item.adminReply ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Submission Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                        StatusChip(status: selectedStatus),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text('Tracking ID: ${item.complaintId}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          item.isAnonymous ? Icons.person_off_outlined : Icons.person_outline_rounded,
                          size: 14,
                          color: item.isAnonymous ? Colors.deepOrange : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Student: ${item.isAnonymous || item.userName == null || item.userName!.trim().isEmpty ? "Anonymous" : item.userName}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.isAnonymous ? Colors.deepOrange : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Type: ${item.type.toUpperCase()}  •  Category: ${item.category}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                    Text('Department: ${item.department}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                    const Divider(height: 24),

                    Text('User Description:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(item.description, style: GoogleFonts.poppins(fontSize: 13, height: 1.4)),
                    ),

                    if (item.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Text('Update Status:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(value: AppConstants.statusPending, child: Text(AppConstants.statusPending)),
                        DropdownMenuItem(value: AppConstants.statusInProgress, child: Text(AppConstants.statusInProgress)),
                        DropdownMenuItem(value: AppConstants.statusResolved, child: Text(AppConstants.statusResolved)),
                        DropdownMenuItem(value: AppConstants.statusRejected, child: Text(AppConstants.statusRejected)),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStatus = val);
                      },
                    ),

                    const SizedBox(height: 16),
                    Text('Admin Response / Reply Note:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: replyCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter official admin response for the user...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Save Status Update',
                      isLoading: isSaving,
                      onPressed: () async {
                        setModalState(() => isSaving = true);
                        final success = await context.read<ComplaintService>().updateComplaintStatus(
                          complaintId: item.complaintId,
                          newStatus: selectedStatus,
                          adminReply: replyCtrl.text.trim(),
                        );
                        setModalState(() => isSaving = false);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Status updated successfully!' : 'Failed to update status.'),
                              backgroundColor: success ? AppColors.greenCard : AppColors.redCard,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── BOTTOM NAVIGATION BAR ───────────────────────────────────────────────────
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _bottomNavIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textGrey,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          label: 'Manage\nComplaints',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline_rounded),
          label: 'Review\nSuggestions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'User\nManagement',
        ),
      ],
    );
  }

  // ── NAVIGATION DRAWER ───────────────────────────────────────────────────────
  Drawer _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color: AppColors.primaryBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset('assets/icons/icon.png', height: 40, width: 40),
                ),
                const SizedBox(height: 12),
                Text('ASCMA',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Anonymous Suggestions & Complaints\nManagement Application',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 8),
                Text('Admin: ${user.name}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryBlue,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isSelected: _currentViewIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.report_problem_outlined,
                    title: 'Complaints',
                    isSelected: _currentViewIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Suggestions',
                    isSelected: _currentViewIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(2);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    title: 'User Management',
                    isSelected: _currentViewIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.analytics_outlined,
                    title: 'Reports & Analytics',
                    isSelected: _currentViewIndex == 5,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(5);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_none,
                    title: 'Notifications Log',
                    isSelected: _currentViewIndex == 6,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(6);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Management',
                    isSelected: _currentViewIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      _switchView(4);
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.white),
                    title: Text('Log Out', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    onTap: () async {
                      await context.read<AuthService>().signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (_) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.amber : Colors.white),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.amber : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white70, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
