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
import '../../widgets/widgets.dart';
import '../auth/welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    // Handle navigation actions here
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AscmaAppBar(
        title:     'Admin Panel',
        showMenu:  true,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: _buildDrawer(context, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, ${user.name} 👋',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Welcome back',
              style: GoogleFonts.poppins(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // Dashboard Grid Cards
            Row(
              children: [
                const Expanded(
                  child: _DashboardStatCard(
                    title: 'Pending\nComplaints',
                    value: '28', // Mock data
                    color: Color(0xFFEF5350),
                    icon: Icons.campaign_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _DashboardStatCard(
                    title: 'Pending\nSuggestions',
                    value: '20', // Mock data
                    color: Color(0xFF26A69A),
                    icon: Icons.lightbulb_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: _DashboardStatCard(
                    title: 'Total\nUsers',
                    value: '1258', // Mock data
                    color: Color(0xFF7E57C2),
                    icon: Icons.person_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _DashboardStatCard(
                    title: 'Resolved\nCases',
                    value: '784', // Mock data
                    color: Color(0xFF66BB6A),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Submissions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Submissions',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All >',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            // Mock Submissions List
            const _SubmissionItem(id: 'ASC5847', type: 'Complaint', time: '03:45pm'),
            const _SubmissionItem(id: 'ASC5846', type: 'Suggestion', time: '6h', isRead: false),
            const _SubmissionItem(id: 'ASC5845', type: 'Suggestion', time: '1d', isRead: false),

            const SizedBox(height: 16),

            // Recent Users Activity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Users Activity',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All >',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            // Mock Users Activity List
            const _UserActivityItem(userId: '4375', action: 'Suggestion'),
            const _UserActivityItem(userId: '4521', action: 'Complaint'),
            const _UserActivityItem(userId: '9635', action: 'Complaint'),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavTap,
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

  Drawer _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color:   AppColors.primaryBlue,
            child:   Column(
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryBlue,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(icon: Icons.dashboard_outlined, title: 'Dashboard', onTap: () {}),
                  _DrawerItem(icon: Icons.report_problem_outlined, title: 'Complaints', onTap: () {}),
                  _DrawerItem(icon: Icons.lightbulb_outline, title: 'Suggestions', onTap: () {}),
                  _DrawerItem(icon: Icons.people_outline, title: 'User Management', onTap: () {}),
                  _DrawerItem(icon: Icons.analytics_outlined, title: 'Report', onTap: () {}),
                  _DrawerItem(icon: Icons.notifications_none, title: 'Notification', onTap: () {}),
                  _DrawerItem(icon: Icons.admin_panel_settings_outlined, title: 'Admin Management', onTap: () {}),
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
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
      onTap: onTap,
    );
  }
}


// ─── Custom Widgets ─────────────────────────────────────────────────────────

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SubmissionItem extends StatelessWidget {
  final String id;
  final String type;
  final String time;
  final bool isRead;

  const _SubmissionItem({
    required this.id,
    required this.type,
    required this.time,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplaint = type.toLowerCase() == 'complaint';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue tint
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ID', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey)),
              Text(id, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Type', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey)),
              Text(
                type,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isComplaint ? const Color(0xFFEF5350) : const Color(0xFF26A69A),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(time, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
              if (!isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class _UserActivityItem extends StatelessWidget {
  final String userId;
  final String action;

  const _UserActivityItem({
    required this.userId,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.textGrey, size: 20),
              const SizedBox(width: 8),
              Text(
                'User',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGrey),
              ),
            ],
          ),
          Text('****$userId', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Text(action, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
