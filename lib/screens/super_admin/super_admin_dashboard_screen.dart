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
    _tabCtrl = TabController(length: 2, vsync: this);
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
      appBar: AscmaAppBar(title: 'Super Admin'),
      body: Column(
        children: [
          // ── Analytics Strip ───────────────────────────────────────────────
          FutureBuilder<Map<String, int>>(
            future: context.read<ComplaintService>().getAnalytics(),
            builder: (context, snap) {
              final data = snap.data ?? {};
              return _AnalyticsStrip(analytics: data);
            },
          ),

          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            color: AppColors.cardWhite,
            child: TabBar(
              controller:        _tabCtrl,
              labelColor:        AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor:    AppColors.primaryBlue,
              labelStyle:        GoogleFonts.poppins(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'All Complaints'),
                Tab(text: 'Manage Admins'),
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
            return Container(
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
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('ID: ${item.complaintId}  •  Dept: ${item.department}',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textGrey)),
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: item.status),
                ],
              ),
            );
          },
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Admin Account',
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
    );
  }
}
