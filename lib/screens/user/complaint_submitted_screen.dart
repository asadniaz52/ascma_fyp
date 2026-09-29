// ─── Complaint Submitted Screen ────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import 'home_screen.dart';

class ComplaintSubmittedScreen extends StatefulWidget {
  final String trackingId;
  final String type; // 'complaint' | 'suggestion'

  const ComplaintSubmittedScreen({
    super.key,
    required this.trackingId,
    this.type = 'complaint',
  });

  @override
  State<ComplaintSubmittedScreen> createState() => _ComplaintSubmittedScreenState();
}

class _ComplaintSubmittedScreenState extends State<ComplaintSubmittedScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
    );

    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _fadeCtrl.forward());
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: widget.trackingId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text('Tracking ID copied!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.greenCard,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration:        const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComplaint = widget.type == 'complaint';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated Check Icon ─────────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width:  120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenCard.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.greenCard.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size:  72,
                    color: AppColors.greenCard,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ───────────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      isComplaint ? 'Complaint Submitted!' : 'Suggestion Submitted!',
                      style: GoogleFonts.poppins(
                        fontSize:   24,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Tracking ID',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color:    AppColors.textGrey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Tracking ID Chip ─────────────────────────────────────
                    GestureDetector(
                      onTap: _copyId,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color:        AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                          border:       Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.trackingId,
                              style: GoogleFonts.poppins(
                                fontSize:      22,
                                fontWeight:    FontWeight.w800,
                                color:         AppColors.primaryBlue,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.copy_rounded,
                                size: 18, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Submission Info ──────────────────────────────────────
                    Container(
                      width:   double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.greenCard, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Submission Received',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize:   14,
                              color:      AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Your ${widget.type} has been successfully received by the administration.',
                            textAlign: TextAlign.center,
                            style:     GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Back to Home ─────────────────────────────────────────
                    PrimaryButton(
                      text:      'Back to Home',
                      icon:      Icons.home_rounded,
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (_) => false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const PrivacyBadge(),
            ],
          ),
        ),
      ),
    );
  }
}
