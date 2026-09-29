// ─── Home Screen ───────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import '../auth/welcome_screen.dart';
import 'notifications_screen.dart';
import 'submit_complaint_screen.dart';
import 'submit_suggestion_screen.dart';
import 'track_status_screen.dart';
import 'about_screen.dart';
import 'my_submissions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _trackingCtrl  = TextEditingController();
  int   _selectedIndex = 0;
  int   _notifCount    = 0;
  StreamSubscription? _notifSub;

  @override
  void initState() {
    super.initState();
    _listenNotifications();
  }

  void _listenNotifications() {
    final authService = context.read<AuthService>();
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      final notifService = context.read<NotificationService>();
      _notifSub = notifService.unreadCount(uid).listen((count) {
        if (mounted) setState(() => _notifCount = count);
      });
    }
  }

  @override
  void dispose() {
    _trackingCtrl.dispose();
    _notifSub?.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: break; // Home
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TrackStatusScreen()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AboutScreen()));
        break;
    }
    if (index != 0) setState(() => _selectedIndex = 0);
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      drawer: _buildDrawer(context),

      appBar: AscmaAppBar(
        notificationCount: _notifCount,
        onBellTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Submit Cards Row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    gradient:  AppColors.complaintGradient,
                    icon:      Icons.campaign_rounded,
                    title:     'Submit\nComplaint',
                    subtitle:  'Report issues anonymously',
                    onTap:     () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SubmitComplaintScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    gradient:  AppColors.suggestionGradient,
                    icon:      Icons.lightbulb_rounded,
                    title:     'Submit\nSuggestion',
                    subtitle:  'Help us improve by sharing your valuable suggestions',
                    onTap:     () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SubmitSuggestionScreen())),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Track Submission ──────────────────────────────────────────────
            Text(
              'Track your submission',
              style: GoogleFonts.poppins(
                fontSize:   15,
                fontWeight: FontWeight.w600,
                color:      AppColors.textDark,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    hint:       'Enter Tracking ID',
                    prefixIcon: Icons.search_rounded,
                    controller: _trackingCtrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text:   'Check Status',
                    height: 52,
                    onPressed: () {
                      final id = _trackingCtrl.text.trim();
                      if (id.isEmpty) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackStatusScreen(trackingId: id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Privacy Badge ─────────────────────────────────────────────────
            const PrivacyBadge(),

            const SizedBox(height: 16),

            // ── Stats Bar ─────────────────────────────────────────────────────
            FutureBuilder<Map<String, int>>(
              future: context.read<ComplaintService>().getAnalytics(),
              builder: (context, snap) {
                final data = snap.data ?? {};
                return StatsBar(
                  total:      data['total']      ?? 0,
                  inProgress: data['inProgress'] ?? 0,
                  resolved:   data['resolved']   ?? 0,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ── Bottom Nav ────────────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap:        _onNavTap,
        type:         BottomNavigationBarType.fixed,
        selectedItemColor:   AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle:  GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Submit'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded),       label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'About'),
        ],
      ),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────────
  Drawer _buildDrawer(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    final menuItems = [
      _DrawerItem(icon: Icons.home_rounded,           label: 'Home',             onTap: () => Navigator.pop(context)),
      _DrawerItem(icon: Icons.campaign_rounded,        label: 'Submit Complaint', onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()));
      }),
      _DrawerItem(icon: Icons.lightbulb_rounded,       label: 'Submit Suggestion', onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitSuggestionScreen()));
      }),
      _DrawerItem(icon: Icons.track_changes_rounded,   label: 'Track Status',    onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackStatusScreen()));
      }),
      _DrawerItem(icon: Icons.list_alt_rounded,        label: 'My Submissions',  onTap: () {
        Navigator.pop(context);
        if (user != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubmissionsScreen()));
        }
      }),
      _DrawerItem(icon: Icons.notifications_rounded,   label: 'Notifications',   onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      }),
      _DrawerItem(icon: Icons.info_outline_rounded,    label: 'About ASCMA',     onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
      }),
      _DrawerItem(icon: Icons.privacy_tip_outlined,    label: 'Privacy Policy',  onTap: () => Navigator.pop(context)),
      _DrawerItem(icon: Icons.logout_rounded,          label: 'Logout',          onTap: _logout, isRed: true),
    ];

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
                const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text('ASCMA', style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                Text(user?.name ?? 'Student',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                if (user?.studentId != null && user!.studentId!.isNotEmpty)
                  Text('ID: ${user.studentId}',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                if (user?.departmentName != null && user!.departmentName!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.departmentName!,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                Text(user?.email ?? '',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuItems.map((item) => ListTile(
                leading:  Icon(item.icon, color: item.isRed ? AppColors.redCard : AppColors.primaryBlue),
                title:    Text(item.label, style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: item.isRed ? AppColors.redCard : AppColors.textDark,
                )),
                onTap:    item.onTap,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Card ──────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData       icon;
  final String         title;
  final String         subtitle;
  final VoidCallback   onTap;

  const _ActionCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient:     gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                color:      Colors.white,
                fontWeight: FontWeight.w700,
                fontSize:   15,
                height:     1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color:    Colors.white70,
                fontSize: 11,
                height:   1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer Item Model ────────────────────────────────────────────────────────
class _DrawerItem {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         isRed;

  _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRed = false,
  });
}
