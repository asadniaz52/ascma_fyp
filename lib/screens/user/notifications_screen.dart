// ─── Notifications Screen ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/ascma_app_bar.dart';
import 'track_status_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final notifService = context.read<NotificationService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const AscmaAppBar(
        title: 'Notifications',
        showMenu: false,
        showBell: false,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view notifications'))
          : StreamBuilder<List<NotificationItem>>(
              stream: notifService.getUserNotifications(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  );
                }

                final notifs = snapshot.data ?? [];
                if (notifs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifs[index];
                    final isRead = item.isRead;
                    final complaintId = item.trackingId;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? AppColors.cardWhite : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(14),
                        border: isRead
                            ? Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5))
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isRead
                                ? Colors.black.withValues(alpha: 0.04)
                                : AppColors.primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isRead ? AppColors.textDark : Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy • hh:mm a').format(item.createdAt),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: isRead ? AppColors.textGrey : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.body,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isRead ? AppColors.textDark : Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isRead)
                                GestureDetector(
                                  onTap: () => notifService.markAsRead(item.id),
                                  child: Text(
                                    'Mark as read',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              if (complaintId != null && complaintId.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    if (!isRead) notifService.markAsRead(item.id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TrackStatusScreen(trackingId: complaintId),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View Submission →',
                                    style: GoogleFonts.poppins(
                                      color: isRead ? AppColors.primaryBlue : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
