// ─── ASCMA AppBar Widget ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/user/notifications_screen.dart';

class AscmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final bool showBell;
  final int notificationCount;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;

  const AscmaAppBar({
    super.key,
    this.title = 'ASCMA',
    this.showMenu = true,
    this.showBell = true,
    this.notificationCount = 0,
    this.onMenuTap,
    this.onBellTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(104);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Top Bar ───────────────────────────────────────────────────────────
        Container(
          color: AppColors.primaryBlue,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Row(
            children: [
              if (showMenu)
                Builder(
                  builder: (scaffoldCtx) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textWhite),
                    onPressed: onMenuTap ?? () => Scaffold.of(scaffoldCtx).openDrawer(),
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (showBell)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.textWhite, size: 26),
                      onPressed: onBellTap ?? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 8,
                        top:  8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.redCard,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        // ── Sub-header banner ─────────────────────────────────────────────────
        Container(
          color: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASCMA',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Anonymous Suggestions & Complaints Management Application',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
