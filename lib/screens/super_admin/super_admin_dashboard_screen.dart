// ─── Super Admin Dashboard Screen ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/complaint_model.dart';
import '../../models/department_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../services/department_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../auth/welcome_screen.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user        = authService.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AscmaAppBar(
        title: 'University Admin',
        showMenu: true,
      ),
      drawer: _buildDrawer(context, user),
      body: Column(
        children: [
          // ── Analytics Strip (Real-time Stream) ───────────────────────────
          StreamBuilder<Map<String, int>>(
            stream: context.read<ComplaintService>().getRealtimeAnalytics(user),
            builder: (context, snap) {
              final data = snap.data ?? {};
              return _AnalyticsStrip(analytics: data);
            },
          ),

          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            color: AppColors.cardWhite,
            child: TabBar(
              controller:           _tabCtrl,
              isScrollable:         true,
              labelColor:           AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor:       AppColors.primaryBlue,
              labelStyle:           GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
              tabs: const [
                Tab(text: 'Referred Queue'),
                Tab(text: 'Department Admins'),
                Tab(text: 'Departments'),
                Tab(text: 'Students List'),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ReferredComplaintsTab(user: user),
                _ManageAdminsTab(),
                _ManageDepartmentsTab(),
                _AllStudentsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await authService.signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            );
          }
        },
        backgroundColor: AppColors.redCard,
        icon:            const Icon(Icons.logout_rounded, color: Colors.white),
        label:           Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              color: AppColors.primaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_rounded, size: 36, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  Text('ASCMA',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  Text('University Super Admin Control',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(icon: Icons.forward_to_inbox_rounded, title: 'Referred Submissions', tabIndex: 0),
                  _drawerItem(icon: Icons.admin_panel_settings_outlined, title: 'Department Admins', tabIndex: 1),
                  _drawerItem(icon: Icons.domain_rounded, title: 'Departments Management', tabIndex: 2),
                  _drawerItem(icon: Icons.people_outline_rounded, title: 'Registered Students', tabIndex: 3),
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

  Widget _drawerItem({required IconData icon, required String title, required int tabIndex}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      onTap: () {
        Navigator.pop(context);
        _tabCtrl.animateTo(tabIndex);
      },
    );
  }
}

// ─── Analytics Strip ──────────────────────────────────────────────────────────
class _AnalyticsStrip extends StatelessWidget {
  final Map<String, int> analytics;
  const _AnalyticsStrip({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   AppColors.primaryBlue.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _StatChip(label: 'Total Items', count: analytics['total']    ?? 0, color: AppColors.primaryBlue),
          _StatChip(label: 'Pending',     count: analytics['pending']  ?? 0, color: AppColors.pending),
          _StatChip(label: 'Referred',    count: analytics['referred'] ?? 0, color: const Color(0xFF7B1FA2)),
          _StatChip(label: 'Resolved',    count: analytics['resolved'] ?? 0, color: AppColors.greenCard),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int    count;
  final Color  color;

  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize:   16,
                color:      color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 1. REFERRED COMPLAINTS TAB (SUPER ADMIN QUEUE) ───────────────────────────
class _ReferredComplaintsTab extends StatelessWidget {
  final UserModel user;
  const _ReferredComplaintsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: context.read<ComplaintService>().getComplaintsByRole(user),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ));
        }

        final items = snap.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 54, color: AppColors.textGrey),
                const SizedBox(height: 12),
                Text(
                  'No referred complaints in queue.',
                  style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Department complaints appear here when referred by Department Admins.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 11),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding:     const EdgeInsets.all(14),
          itemCount:   items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _showStatusUpdateDialog(context, item, user),
              child: Container(
                margin:  const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:        AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: const Color(0xFFCE93D8)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
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
                            item.category,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryBlue),
                          ),
                        ),
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('ID: ${item.complaintId}  •  Dept: ${item.departmentName}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                    if (item.referralReason != null && item.referralReason!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Referral Reason: ${item.referralReason}',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7B1FA2), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark),
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

  void _showStatusUpdateDialog(BuildContext context, ComplaintModel item, UserModel user) {
    String selectedStatus = item.status;
    final replyCtrl = TextEditingController(text: item.adminReply ?? '');
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Referred Submission: ${item.complaintId}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item.isAnonymous ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
                          size: 15,
                          color: item.isAnonymous ? Colors.deepOrange : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Student: ${item.isAnonymous || item.userName == null || item.userName!.trim().isEmpty ? "Anonymous" : item.userName}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: item.isAnonymous ? Colors.deepOrange : AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Category: ${item.category}', style: GoogleFonts.poppins(fontSize: 12)),
                    Text('Department: ${item.departmentName}', style: GoogleFonts.poppins(fontSize: 12)),
                    if (item.referralReason != null) ...[
                      const SizedBox(height: 8),
                      Text('Department Referral Reason:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF7B1FA2))),
                      Text(item.referralReason!, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark)),
                    ],
                    const SizedBox(height: 10),
                    Text('Student Description:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(item.description, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(height: 14),

                    Text('Update Status:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      items: [
                        DropdownMenuItem(value: AppConstants.statusPending,    child: Text(AppConstants.statusPending)),
                        DropdownMenuItem(value: AppConstants.statusInProgress, child: Text(AppConstants.statusInProgress)),
                        DropdownMenuItem(value: AppConstants.statusResolved,   child: Text(AppConstants.statusResolved)),
                        DropdownMenuItem(value: AppConstants.statusRejected,   child: Text(AppConstants.statusRejected)),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => selectedStatus = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('University Admin Note / Reply:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    TextField(
                      controller: replyCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(hintText: 'Official resolution response...'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  onPressed: isUpdating
                      ? null
                      : () async {
                          setDlgState(() => isUpdating = true);
                          await context.read<ComplaintService>().updateComplaintStatus(
                            complaintId: item.complaintId,
                            newStatus:   selectedStatus,
                            adminReply:  replyCtrl.text.trim(),
                            admin:       user,
                          );
                          setDlgState(() => isUpdating = false);
                          if (context.mounted) Navigator.pop(dlgCtx);
                        },
                  child: const Text('Update Status', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── 2. MANAGE ADMINS TAB ─────────────────────────────────────────────────────
class _ManageAdminsTab extends StatefulWidget {
  @override
  State<_ManageAdminsTab> createState() => _ManageAdminsTabState();
}

class _ManageAdminsTabState extends State<_ManageAdminsTab> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  DepartmentModel? _selectedDept;
  String _selectedRole = AppConstants.roleDepartmentAdmin;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == AppConstants.roleDepartmentAdmin && _selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please assign a department to the Department Admin'),
        backgroundColor: AppColors.redCard,
      ));
      return;
    }

    final authService = context.read<AuthService>();
    final error = await authService.createAdminAccount(
      name:           _nameCtrl.text.trim(),
      email:          _emailCtrl.text.trim(),
      password:       _passCtrl.text.trim(),
      role:           _selectedRole,
      departmentId:   _selectedDept?.departmentId,
      departmentName: _selectedDept?.name,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        error ?? 'Admin account created successfully!',
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: error != null ? AppColors.redCard : AppColors.greenCard,
      behavior:        SnackBarBehavior.floating,
      shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    if (error == null) {
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      setState(() => _selectedDept = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Create Admin Form Card ───────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Admin Account',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryBlue)),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hint:       'Admin Full Name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameCtrl,
                      validator:  (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hint:        'Email Address',
                      prefixIcon:  Icons.email_outlined,
                      controller:  _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator:   (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      hint:       'Password (min 6 chars)',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passCtrl,
                      validator:  (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 10),

                    // Role Selector
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        labelText: 'Admin Role',
                      ),
                      items: const [
                        DropdownMenuItem(value: AppConstants.roleDepartmentAdmin, child: Text('Department Admin')),
                        DropdownMenuItem(value: AppConstants.roleGeneralAdmin,    child: Text('General Admin')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedRole = v);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Department Dropdown
                    if (_selectedRole == AppConstants.roleDepartmentAdmin)
                      StreamBuilder<List<DepartmentModel>>(
                        stream: context.read<DepartmentService>().getDepartmentsStream(onlyActive: true),
                        builder: (context, snap) {
                          final depts = snap.data ?? [];
                          DepartmentModel? currentVal;
                          if (_selectedDept != null &&
                              depts.any((d) => d.departmentId == _selectedDept!.departmentId)) {
                            currentVal = depts.firstWhere((d) => d.departmentId == _selectedDept!.departmentId);
                          }

                          return DropdownButtonFormField<DepartmentModel>(
                            initialValue: currentVal,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              labelText: 'Assigned Department *',
                            ),
                            items: depts.map((d) {
                              return DropdownMenuItem(value: d, child: Text(d.name, style: GoogleFonts.poppins(fontSize: 13)));
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedDept = v),
                            validator: (v) => v == null ? 'Department is mandatory' : null,
                          );
                        },
                      ),

                    const SizedBox(height: 16),
                    PrimaryButton(
                      text:      'Create Admin Account',
                      isLoading: authService.isLoading,
                      onPressed: _createAdmin,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Existing Admins List ─────────────────────────────────────────
          Text('Existing Admins',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
          const SizedBox(height: 8),

          StreamBuilder<List<UserModel>>(
            stream: authService.getAdmins(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final admins = snap.data ?? [];
              if (admins.isEmpty) {
                return Center(child: Text('No admins created yet.', style: GoogleFonts.poppins(color: AppColors.textGrey)));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                itemCount:  admins.length,
                itemBuilder: (context, index) {
                  final a = admins[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        child: Icon(a.isSuperAdmin ? Icons.shield_rounded : Icons.person, color: AppColors.primaryBlue),
                      ),
                      title: Text(a.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text('${a.email}\nDept: ${a.departmentName ?? "General"} • Role: ${a.roleDisplay}',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                      isThreeLine: true,
                      trailing: Switch(
                        value: a.isActive,
                        activeThumbColor: AppColors.greenCard,
                        onChanged: a.isSuperAdmin ? null : (val) async {
                          await authService.toggleUserStatus(a.uid, a.isActive);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── 3. MANAGE DEPARTMENTS TAB ────────────────────────────────────────────────
class _ManageDepartmentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deptService = context.watch<DepartmentService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: StreamBuilder<List<DepartmentModel>>(
        stream: deptService.getDepartmentsStream(onlyActive: false),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final depts = snap.data ?? [];
          if (depts.isEmpty) {
            return Center(child: Text('No departments found.', style: GoogleFonts.poppins(color: AppColors.textGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: depts.length,
            itemBuilder: (context, index) {
              final d = depts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(d.code, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                  ),
                  title: Text(d.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(d.isActive ? 'Status: Active' : 'Status: Inactive',
                      style: GoogleFonts.poppins(fontSize: 11, color: d.isActive ? Colors.green : Colors.red)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: d.isActive,
                        activeThumbColor: AppColors.greenCard,
                        onChanged: (v) async {
                          await deptService.toggleDepartmentStatus(d.departmentId, d.isActive);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showEditDepartmentDialog(context, d),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDepartmentDialog(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDepartmentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Add New Department', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Department Name (e.g. Cyber Security)')),
            const SizedBox(height: 10),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (e.g. CYS)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty && codeCtrl.text.trim().isNotEmpty) {
                await context.read<DepartmentService>().addDepartment(
                  name: nameCtrl.text.trim(),
                  code: codeCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(dlgCtx);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, DepartmentModel d) {
    final nameCtrl = TextEditingController(text: d.name);
    final codeCtrl = TextEditingController(text: d.code);

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text('Edit Department', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Department Name')),
            const SizedBox(height: 10),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              await context.read<DepartmentService>().updateDepartment(
                departmentId: d.departmentId,
                name:         nameCtrl.text.trim(),
                code:         codeCtrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(dlgCtx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── 4. ALL STUDENTS TAB ──────────────────────────────────────────────────────
class _AllStudentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return StreamBuilder<List<UserModel>>(
      stream: authService.getStudents(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final students = snap.data ?? [];
        if (students.isEmpty) {
          return Center(
            child: Text('No registered students found.', style: GoogleFonts.poppins(color: AppColors.textGrey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final s = students[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ),
                title: Text(s.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(
                  'ID: ${s.studentId ?? "N/A"}  •  Dept: ${s.departmentName ?? "General"}\nEmail: ${s.email}',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                ),
                isThreeLine: true,
                trailing: Switch(
                  value: s.isActive,
                  activeThumbColor: AppColors.greenCard,
                  onChanged: (val) async {
                    await authService.toggleUserStatus(s.uid, s.isActive);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
