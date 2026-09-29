// ─── Department Admin Dashboard Screen ─────────────────────────────────────────
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
  int _currentViewIndex = 0; // 0: Overview, 1: Complaints, 2: Suggestions, 3: Referred, 4: Reports, 5: Notifications
  int _bottomNavIndex = 0;
  String _statusFilter = '';

  void _onBottomNavTap(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) _currentViewIndex = 0; // Overview
      if (index == 1) _currentViewIndex = 1; // Complaints
      if (index == 2) _currentViewIndex = 2; // Suggestions
      if (index == 3) _currentViewIndex = 4; // Reports
    });
  }

  void _switchView(int index) {
    setState(() {
      _currentViewIndex = index;
      if (index == 0) _bottomNavIndex = 0;
      if (index == 1) _bottomNavIndex = 1;
      if (index == 2) _bottomNavIndex = 2;
      if (index == 4) _bottomNavIndex = 3;
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
      case 0: return 'Department Overview';
      case 1: return 'Department Complaints';
      case 2: return 'Department Suggestions';
      case 3: return 'Referred Submissions';
      case 4: return 'Reports & Analytics';
      case 5: return 'Department Notifications';
      default: return 'Department Admin';
    }
  }

  Widget _buildCurrentView(UserModel user) {
    switch (_currentViewIndex) {
      case 0: return _buildDashboardOverview(user);
      case 1: return _buildComplaintsView(user, type: 'complaint');
      case 2: return _buildComplaintsView(user, type: 'suggestion');
      case 3: return _buildReferredView(user);
      case 4: return _buildReportsView(user);
      case 5: return _buildNotificationsLogView(user);
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
          // Greeting & Department Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Welcome, ${user.name}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Dept Admin',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Department: ${user.departmentName ?? user.departmentId ?? "General"}',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Real-time Stat Cards Grid (Filtered for this Department Only)
          StreamBuilder<Map<String, int>>(
            stream: context.read<ComplaintService>().getRealtimeAnalytics(user),
            builder: (context, snapAnalytics) {
              final stats = snapAnalytics.data ?? {};
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
                          title: 'Under Process\n(In Progress)',
                          value: '${stats['inProgress'] ?? 0}',
                          color: AppColors.primaryBlue,
                          icon: Icons.sync_rounded,
                          onTap: () => _switchView(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardStatCard(
                          title: 'Referred to\nSuper Admin',
                          value: '${stats['referred'] ?? 0}',
                          color: const Color(0xFF7B1FA2),
                          icon: Icons.forward_to_inbox_rounded,
                          onTap: () => _switchView(3),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),

          // Recent Submissions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Department Submissions',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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

          // Submissions Stream
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textGrey),
                        const SizedBox(height: 8),
                        Text(
                          'No submissions received for ${user.departmentName ?? "your department"} yet.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final recent = items.take(4).toList();
              return Column(
                children: recent.map((item) => _buildSubmissionTile(context, item, user)).toList(),
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
                _buildFilterChip('Referred', AppConstants.statusReferred),
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
                        size: 60,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No ${isComplaint ? "complaints" : "suggestions"} found',
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildSubmissionTile(context, items[index], user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 3. REFERRED SUBMISSIONS VIEW ─────────────────────────────────────────────
  Widget _buildReferredView(UserModel user) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: context.read<ComplaintService>().getComplaintsByRole(user, statusFilter: AppConstants.statusReferred),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forward_to_inbox_rounded, size: 54, color: AppColors.textGrey),
                const SizedBox(height: 12),
                Text(
                  'No referred complaints.',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildSubmissionTile(context, items[index], user);
          },
        );
      },
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

  // ── 4. REPORTS & ANALYTICS VIEW ─────────────────────────────────────────────
  Widget _buildReportsView(UserModel user) {
    return StreamBuilder<Map<String, int>>(
      stream: context.read<ComplaintService>().getRealtimeAnalytics(user),
      builder: (context, snap) {
        final data = snap.data ?? {};
        final total = data['total'] ?? 0;
        final resolved = data['resolved'] ?? 0;
        final pending = data['pending'] ?? 0;
        final inProgress = data['inProgress'] ?? 0;
        final referred = data['referred'] ?? 0;
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
                    Text('${user.departmentName ?? "Department"} Resolution Rate', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('$resolutionRate%',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Total Department Submissions: $total',
                      style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Department Status Breakdown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              _buildReportCard('Pending Review', '$pending', const Color(0xFFEF5350), Icons.hourglass_top),
              _buildReportCard('Under Process', '$inProgress', AppColors.primaryBlue, Icons.sync),
              _buildReportCard('Referred to Super Admin', '$referred', const Color(0xFF7B1FA2), Icons.forward_to_inbox_rounded),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          Text(count, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  // ── 5. NOTIFICATIONS LOG VIEW ────────────────────────────────────────────────
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
                onTap: () => _showSubmissionDetailModal(context, item, user),
              ),
            );
          },
        );
      },
    );
  }

  // ── REUSABLE SUBMISSION TILE ─────────────────────────────────────────────────
  Widget _buildSubmissionTile(BuildContext context, ComplaintModel item, UserModel user) {
    final bool isComplaint = item.type.toLowerCase() == 'complaint';
    final fmt = DateFormat('dd MMM, hh:mm a');

    return GestureDetector(
      onTap: () => _showSubmissionDetailModal(context, item, user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
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
                color: (isComplaint ? const Color(0xFFEF5350) : const Color(0xFF26A69A)).withValues(alpha: 0.12),
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
                        item.isAnonymous ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
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
                  Text('ID: ${item.complaintId}  •  Dept: ${item.departmentName}',
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

  // ── SUBMISSION DETAIL & UPDATE MODAL (WITH REFERRAL WORKFLOW) ────────────────
  void _showSubmissionDetailModal(BuildContext context, ComplaintModel item, UserModel user) {
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
                          item.isAnonymous ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
                          size: 14,
                          color: item.isAnonymous ? Colors.deepOrange : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Student: ${item.isAnonymous || item.userName == null || item.userName!.trim().isEmpty ? "Anonymous Student" : item.userName}',
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
                    Text('Department: ${item.departmentName}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                    const Divider(height: 24),

                    Text('Description:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
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

                    // ── Status Update Section ───────────────────────────────
                    Text('Update Status:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem(value: AppConstants.statusPending,    child: Text(AppConstants.statusPending)),
                        DropdownMenuItem(value: AppConstants.statusInProgress, child: Text(AppConstants.statusInProgress)),
                        DropdownMenuItem(value: AppConstants.statusResolved,   child: Text(AppConstants.statusResolved)),
                        DropdownMenuItem(value: AppConstants.statusRejected,   child: Text(AppConstants.statusRejected)),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedStatus = val);
                      },
                    ),

                    const SizedBox(height: 16),
                    Text('Department Official Response:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: replyCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter official department reply note for the student...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons Row: Save Status & Refer to Super Admin
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Save Status',
                            isLoading: isSaving,
                            onPressed: () async {
                              setModalState(() => isSaving = true);
                              final success = await context.read<ComplaintService>().updateComplaintStatus(
                                complaintId: item.complaintId,
                                newStatus:   selectedStatus,
                                adminReply:  replyCtrl.text.trim(),
                                admin:       user,
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
                        ),
                        const SizedBox(width: 10),
                        // ── "Refer to Super Admin" Button ─────────────────────
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B1FA2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.forward_to_inbox_rounded, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Refer to Super Admin',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              _showReferralDialog(context, item, user);
                            },
                          ),
                        ),
                      ],
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

  // ── REFERRAL DIALOG (MANDATORY REASON) ───────────────────────────────────────
  void _showReferralDialog(BuildContext context, ComplaintModel item, UserModel user) {
    final reasonCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.forward_to_inbox_rounded, color: Color(0xFF7B1FA2)),
                  const SizedBox(width: 8),
                  Text('Refer to Super Admin', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalate ${item.complaintId} to University Administration.',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Referral Reason (Mandatory) *',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. Department cannot resolve because university-level budget approval is required...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B1FA2)),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (reasonCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please provide a referral reason.'),
                                backgroundColor: AppColors.redCard,
                              ),
                            );
                            return;
                          }

                          setDlgState(() => isSubmitting = true);
                          final success = await context.read<ComplaintService>().referComplaintToSuperAdmin(
                            complaintId:    item.complaintId,
                            referralReason: reasonCtrl.text.trim(),
                            admin:          user,
                          );
                          setDlgState(() => isSubmitting = false);

                          if (context.mounted) {
                            Navigator.pop(dlgCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Complaint successfully referred to Super Admin!' : 'Failed to refer complaint.'),
                                backgroundColor: success ? AppColors.greenCard : AppColors.redCard,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Referral', style: TextStyle(color: Colors.white)),
                ),
              ],
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
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded),      label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded),       label: 'Complaints'),
        BottomNavigationBarItem(icon: Icon(Icons.lightbulb_rounded),      label: 'Suggestions'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),       label: 'Reports'),
      ],
    );
  }

  // ── DRAWER ───────────────────────────────────────────────────────────────────
  Drawer _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              color: AppColors.primaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    user.departmentName ?? 'Department Admin',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(icon: Icons.dashboard_outlined, title: 'Department Overview', index: 0),
                  _drawerItem(icon: Icons.campaign_outlined, title: 'Complaints', index: 1),
                  _drawerItem(icon: Icons.lightbulb_outline, title: 'Suggestions', index: 2),
                  _drawerItem(icon: Icons.forward_to_inbox_rounded, title: 'Referred Queue', index: 3),
                  _drawerItem(icon: Icons.analytics_outlined, title: 'Reports & Analytics', index: 4),
                  _drawerItem(icon: Icons.notifications_none_rounded, title: 'Notifications Log', index: 5),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.white),
              title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, required int index}) {
    final isSelected = _currentViewIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      tileColor: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
      onTap: () {
        Navigator.pop(context);
        _switchView(index);
      },
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 24, color: color),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
