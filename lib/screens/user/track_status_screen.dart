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
            // ── Search Row ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hint:       'Enter Tracking ID',
                    prefixIcon: Icons.search_rounded,
                    controller: _trackingCtrl,
                  ),
                ),
                const SizedBox(width: 10),
                PrimaryButton(
                  text:      'Check Status',
                  width:     120,
                  height:    52,
                  onPressed: _search,
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
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
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
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.greenCard, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Received',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize:   14,
                        color:      AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Your ${complaint.type} has been successfully received by the administration.',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // ── Details ────────────────────────────────────────────────────────
          _DetailRow(label: 'Tracking ID',   value: complaint.complaintId),
          _DetailRow(
            label: 'Submitted by',
            value: complaint.isAnonymous || complaint.userName == null || complaint.userName!.trim().isEmpty
                ? 'Anonymous'
                : complaint.userName!,
          ),
          _DetailRow(label: 'Submitted on',  value: fmt.format(complaint.createdAt)),
          _DetailRow(label: 'Category',      value: complaint.type == 'complaint' ? 'Complaint' : 'Suggestion'),
          _DetailRow(label: 'Sub-Category',  value: complaint.category),

          const Divider(height: 24),

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
            description: 'Completed',
            isCompleted: true,
            color:       AppColors.greenCard,
          ),
          _TimelineStep(
            label:       'Received by Admin',
            description: 'Completed',
            isCompleted: true,
            color:       AppColors.greenCard,
          ),
          _TimelineStep(
            label:       'Under Review',
            description: complaint.status == AppConstants.statusPending
                ? 'Pending'
                : 'Completed',
            isCompleted: complaint.status != AppConstants.statusPending,
            color:       AppColors.pending,
          ),
          _TimelineStep(
            label:       'Admin Response',
            description: complaint.adminReply ?? 'No Response yet',
            isCompleted: complaint.adminReply != null,
            color:       AppColors.primaryBlue,
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
          // ── Timeline Line + Dot ──────────────────────────────────────────
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
                    color: isCompleted ? color.withOpacity(0.4) : const Color(0xFFCFD8DC),
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
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
