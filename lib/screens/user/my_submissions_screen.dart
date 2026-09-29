// ─── My Submissions Screen ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/ascma_app_bar.dart';
import '../../widgets/status_chip.dart';

import 'track_status_screen.dart';

class MySubmissionsScreen extends StatelessWidget {
  const MySubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar:          const AscmaAppBar(showMenu: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'My Submissions',
              style: GoogleFonts.poppins(
                fontSize:   18,
                fontWeight: FontWeight.w700,
                color:      AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ComplaintModel>>(
              stream: context.read<ComplaintService>().getComplaintsByRole(user),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  );
                }

                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.redCard),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load submissions',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Error: ${snap.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snap.data ?? [];

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_rounded,
                            size: 64, color: AppColors.textGrey),
                        const SizedBox(height: 12),
                        Text('No submissions yet',
                            style: GoogleFonts.poppins(
                                fontSize: 15, color: AppColors.textGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:     const EdgeInsets.all(16),
                  itemCount:   items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _SubmissionCard(complaint: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final ComplaintModel complaint;
  const _SubmissionCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    final isComplaint = complaint.type == 'complaint';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackStatusScreen(trackingId: complaint.complaintId),
        ),
      ),
      child: Container(
        margin:  const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color:        (isComplaint ? AppColors.redCard : AppColors.greenCard)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isComplaint ? Icons.campaign_rounded : Icons.lightbulb_rounded,
                color: isComplaint ? AppColors.redCard : AppColors.greenCard,
                size:  24,
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
                          complaint.category,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize:   14,
                            color:      AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: complaint.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'ID: ${complaint.complaintId}',
                        style: GoogleFonts.poppins(
                          fontSize:   11,
                          color:      AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (complaint.departmentName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            complaint.departmentName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.description,
                    maxLines:  2,
                    overflow:  TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:    AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(complaint.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color:    AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
