// ─── Status Chip Widget ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case AppConstants.statusPending:    return AppColors.pending;
      case AppConstants.statusInProgress: return AppColors.inProgress;
      case AppConstants.statusResolved:   return AppColors.resolved;
      case AppConstants.statusReferred:   return const Color(0xFF7B1FA2); // Deep Purple
      case AppConstants.statusRejected:   return AppColors.rejected;
      case AppConstants.statusClosed:     return const Color(0xFF455A64); // Blue Grey
      default:                            return AppColors.textGrey;
    }
  }

  IconData get _icon {
    switch (status) {
      case AppConstants.statusPending:    return Icons.access_time_rounded;
      case AppConstants.statusInProgress: return Icons.loop_rounded;
      case AppConstants.statusResolved:   return Icons.check_circle_rounded;
      case AppConstants.statusReferred:   return Icons.forward_to_inbox_rounded;
      case AppConstants.statusRejected:   return Icons.cancel_rounded;
      case AppConstants.statusClosed:     return Icons.archive_outlined;
      default:                            return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 13),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              color:      _color,
              fontSize:   11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


