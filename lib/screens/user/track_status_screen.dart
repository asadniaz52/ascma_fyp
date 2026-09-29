// ─── Track Status Screen ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

class TrackStatusScreen extends StatefulWidget {
  final String? trackingId;
  const TrackStatusScreen({super.key, this.trackingId});

  @override
  State<TrackStatusScreen> createState() => _TrackStatusScreenState();
}

class _TrackStatusScreenState extends State<TrackStatusScreen> {
  final _trackingCtrl = TextEditingController();
  String? _searchId;
  bool    _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.trackingId != null) {
      _trackingCtrl.text = widget.trackingId!;
      _searchId = widget.trackingId;
      _hasSearched = true;
    }
  }

  @override
  void dispose() {
    _trackingCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final id = _trackingCtrl.text.trim();
    if (id.isEmpty) return;
    setState(() {
      _searchId    = id.toUpperCase();
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar:          const AscmaAppBar(showMenu: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Responsive Search Row (Zero Overflow) ───────────────────────
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    hint:       'Enter Tracking ID (e.g. ASC1234)',
                    prefixIcon: Icons.search_rounded,
                    controller: _trackingCtrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: _search,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Check Status',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Stream Result ─────────────────────────────────────────────────
            if (_hasSearched && _searchId != null)
              StreamBuilder<ComplaintModel?>(
                stream: context.read<ComplaintService>().trackComplaint(_searchId!),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                        ),
                      ),
                    );
                  }

                  if (!snap.hasData || snap.data == null) {
                    return _NotFoundCard(id: _searchId!);
                  }

                  return _TrackingResult(complaint: snap.data!);
                },
              ),

            const SizedBox(height: 20),
            const PrivacyBadge(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }
}

// ─── Tracking Result Card ─────────────────────────────────────────────────────
class _TrackingResult extends StatelessWidget {
  final ComplaintModel complaint;
  const _TrackingResult({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    final isReferred = complaint.status == AppConstants.statusReferred || complaint.referredToSuperAdmin;
    final isResolved = complaint.status == AppConstants.statusResolved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Status Chip ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isResolved ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: isResolved ? AppColors.greenCard : AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tracking: ${complaint.complaintId}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize:   14,
                      color:      AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              StatusChip(status: complaint.status),
            ],
          ),

          const Divider(height: 20),

          // ── Referral Notice if applicable ─────────────────────────────────
          if (isReferred) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCE93D8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.forward_to_inbox_rounded, color: Color(0xFF7B1FA2), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referred to University Administration',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: const Color(0xFF7B1FA2),
                          ),
                        ),
                        Text(
                          'The department administrator has escalated this issue to higher university authority for decision.',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Details ────────────────────────────────────────────────────────
          _DetailRow(label: 'Target Dept',   value: complaint.departmentName),
          _DetailRow(
            label: 'Submitted by',
            value: complaint.isAnonymous || complaint.userName == null || complaint.userName!.trim().isEmpty
                ? 'Anonymous'
                : complaint.userName!,
          ),
          _DetailRow(label: 'Submitted on',  value: fmt.format(complaint.createdAt)),
          _DetailRow(label: 'Category',      value: complaint.category),
          _DetailRow(label: 'Type',          value: complaint.type.toUpperCase()),
          _DetailRow(label: 'Priority',      value: complaint.priority),

          const Divider(height: 20),

          // ── Official Response ──────────────────────────────────────────────
          if (complaint.adminReply != null && complaint.adminReply!.isNotEmpty) ...[
            Text(
              'Official Administrative Response:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBDEFB)),
              ),
              child: Text(
                complaint.adminReply!,
                style: GoogleFonts.poppins(fontSize: 12, height: 1.4, color: AppColors.textDark),
              ),
            ),
            const Divider(height: 24),
          ],

          // ── Status Timeline ────────────────────────────────────────────────
          Text(
            'Status Timeline',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize:   14,
              color:      AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          _TimelineStep(
            label:       'Submission',
            description: 'Received in system',
            isCompleted: true,
            color:       AppColors.greenCard,
          ),
          _TimelineStep(
            label:       'Assigned to ${complaint.departmentName}',
            description: 'Department notified',
            isCompleted: true,
            color:       AppColors.greenCard,
          ),
          _TimelineStep(
            label:       isReferred ? 'Escalated to University Administration' : 'Department Investigation',
            description: complaint.status == AppConstants.statusPending
                ? 'Under Review'
                : (isReferred ? 'Referred for University Action' : 'In Progress'),
            isCompleted: complaint.status != AppConstants.statusPending,
            color:       isReferred ? const Color(0xFF7B1FA2) : AppColors.primaryBlue,
          ),
          _TimelineStep(
            label:       'Resolution',
            description: isResolved ? 'Resolved & Closed' : 'Pending final resolution',
            isCompleted: isResolved,
            color:       AppColors.greenCard,
            isLast:      true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String  label;
  final String  description;
  final bool    isCompleted;
  final Color   color;
  final bool    isLast;

  const _TimelineStep({
    required this.label,
    required this.description,
    required this.isCompleted,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width:  18,
                height: 18,
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  color:  isCompleted ? color : AppColors.surfaceGrey,
                  border: Border.all(
                    color: isCompleted ? color : const Color(0xFFCFD8DC),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? color.withValues(alpha: 0.4) : const Color(0xFFCFD8DC),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize:   13,
                      color:      AppColors.textDark,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:    isCompleted ? color : AppColors.textGrey,
                    ),
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

class _NotFoundCard extends StatelessWidget {
  final String id;
  const _NotFoundCard({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textGrey),
          const SizedBox(height: 12),
          Text(
            'No submission found',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize:   15,
              color:      AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No record found for Tracking ID: $id\nPlease check and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

Widget _bottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex:         2,
    type:                 BottomNavigationBarType.fixed,
    selectedItemColor:    AppColors.primaryBlue,
    unselectedItemColor:  AppColors.textGrey,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded),           label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.description_outlined),   label: 'Submit'),
      BottomNavigationBarItem(icon: Icon(Icons.search_rounded),          label: 'Track'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'About'),
    ],
    onTap: (i) { if (i == 0) Navigator.popUntil(context, (r) => r.isFirst); },
  );
}
