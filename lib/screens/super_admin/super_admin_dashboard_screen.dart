// ─── Super Admin Dashboard Screen ──────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
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
    _tabCtrl = TabController(length: 3, vsync: this);
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
        title: 'Super Admin',
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
              labelColor:           AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor:       AppColors.primaryBlue,
              labelStyle:           GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Submissions'),
                Tab(text: 'Department Admins'),
                Tab(text: 'System Users'),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AllComplaintsTab(user: user),
                _ManageAdminsTab(),
                _AllUsersTab(),
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
        label:           Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

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
                Text('Super Admin Control Panel',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 6),
                Text(user.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryBlue,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined, color: Colors.white),
                    title: Text('All Submissions', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      _tabCtrl.animateTo(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
                    title: Text('Department Admins', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      _tabCtrl.animateTo(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline, color: Colors.white),
                    title: Text('System Users', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      _tabCtrl.animateTo(2);
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

// ─── Analytics Strip ─────────────────────────────────────────────────────────
class _AnalyticsStrip extends StatelessWidget {
  final Map<String, int> analytics;
  const _AnalyticsStrip({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   AppColors.primaryBlue.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _StatChip(label: 'Total',       count: analytics['total']      ?? 0, color: AppColors.primaryBlue),
          _StatChip(label: 'Pending',     count: analytics['pending']    ?? 0, color: AppColors.pending),
          _StatChip(label: 'In Progress', count: analytics['inProgress'] ?? 0, color: AppColors.accentBlue),
          _StatChip(label: 'Resolved',    count: analytics['resolved']   ?? 0, color: AppColors.greenCard),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize:   18,
                color:      color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── All Complaints Tab ───────────────────────────────────────────────────────
class _AllComplaintsTab extends StatelessWidget {
  final UserModel user;
  const _AllComplaintsTab({required this.user});

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
            child: Text('No submissions yet',
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          );
        }

        return ListView.builder(
          padding:     const EdgeInsets.all(16),
          itemCount:   items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _showStatusUpdateDialog(context, item),
              child: Container(
                margin:  const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:        AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.category,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryBlue)),
                          Text('ID: ${item.complaintId}  •  Dept: ${item.department}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppColors.textGrey)),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: item.status),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStatusUpdateDialog(BuildContext context, ComplaintModel item) {
    String selectedStatus = item.status;
    final replyCtrl = TextEditingController(text: item.adminReply ?? '');

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Manage Submission: ${item.complaintId}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${item.category}', style: GoogleFonts.poppins(fontSize: 13)),
                Text('Department: ${item.department}', style: GoogleFonts.poppins(fontSize: 13)),
                const SizedBox(height: 10),
                Text('Description:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(item.description, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 16),
                Text('Status:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStatus,
                  items: [
                    DropdownMenuItem(value: AppConstants.statusPending, child: Text(AppConstants.statusPending)),
                    DropdownMenuItem(value: AppConstants.statusInProgress, child: Text(AppConstants.statusInProgress)),
                    DropdownMenuItem(value: AppConstants.statusResolved, child: Text(AppConstants.statusResolved)),
                    DropdownMenuItem(value: AppConstants.statusRejected, child: Text(AppConstants.statusRejected)),
                  ],
                  onChanged: (v) {
                    if (v != null) selectedStatus = v;
                  },
                ),
                const SizedBox(height: 10),
                Text('Admin Note / Reply:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                TextField(
                  controller: replyCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Response for user...'),
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
              onPressed: () async {
                await context.read<ComplaintService>().updateComplaintStatus(
                  complaintId: item.complaintId,
                  newStatus: selectedStatus,
                  adminReply: replyCtrl.text.trim(),
                );
                if (context.mounted) Navigator.pop(dlgCtx);
              },
              child: const Text('Update Status', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// ─── Manage Admins Tab ────────────────────────────────────────────────────────
class _ManageAdminsTab extends StatefulWidget {
  @override
  State<_ManageAdminsTab> createState() => _ManageAdminsTabState();
}

class _ManageAdminsTabState extends State<_ManageAdminsTab> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  String? _selectedDept;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a department'),
        backgroundColor: AppColors.redCard,
      ));
      return;
    }

    final authService = context.read<AuthService>();
    final error = await authService.createAdminAccount(
      name:       _nameCtrl.text,
      email:      _emailCtrl.text,
      password:   _passCtrl.text,
      department: _selectedDept!,
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
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Department Admin Account',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize:   16,
                    color:      AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint:       'Admin Name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameCtrl,
                  validator:  (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint:        'Admin Email',
                  prefixIcon:  Icons.email_outlined,
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator:   (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (!v!.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint:       'Password (min 6 characters)',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _passCtrl,
                  validator:  (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    if (v!.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value:     _selectedDept,
                  hint:      Text('Select Department',
                      style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14)),
                  decoration: InputDecoration(
                    filled:    true,
                    fillColor: AppColors.cardWhite,
                    border:    OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:  const BorderSide(color: Color(0xFFCFD8DC))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:  const BorderSide(color: Color(0xFFCFD8DC))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  items: AppConstants.departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDept = v),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text:      'Create Admin Account',
                  icon:      Icons.person_add_alt_1_rounded,
                  isLoading: authService.isLoading,
                  onPressed: _createAdmin,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Active Department Admins',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<UserModel>>(
            stream: authService.getAdmins(),
            builder: (context, snap) {
              final admins = snap.data ?? [];
              if (admins.isEmpty) {
                return Center(child: Text('No department admins found.', style: GoogleFonts.poppins(color: AppColors.textGrey)));
              }
              return Column(
                children: admins.map((admin) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.admin_panel_settings, color: Colors.white),
                    ),
                    title: Text(admin.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${admin.email}\nDepartment: ${admin.department ?? "General"}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── System Users Tab ─────────────────────────────────────────────────────────
class _AllUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: context.read<AuthService>().getAllUsers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return Center(child: Text('No users registered.', style: GoogleFonts.poppins(color: AppColors.textGrey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: u.isAdmin ? AppColors.primaryBlue : Colors.grey.shade300,
                  child: Icon(u.isAdmin ? Icons.admin_panel_settings : Icons.person, color: u.isAdmin ? Colors.white : Colors.grey.shade700),
                ),
                title: Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${u.email}  •  Role: ${u.role.toUpperCase()}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
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
}
