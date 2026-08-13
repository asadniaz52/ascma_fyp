// ─── About Screen ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar:          const AscmaAppBar(showMenu: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Logo ───────────────────────────────────────────────────────────
            Container(
              width:  100,
              height: 100,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded,
                  color: Colors.white, size: 56),
            ),

            const SizedBox(height: 16),

            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontSize:   28,
                fontWeight: FontWeight.w900,
                color:      AppColors.primaryBlue,
                letterSpacing: 2,
              ),
            ),

            Text(
              'Version ${AppConstants.appVersion}',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
            ),

            const SizedBox(height: 24),

            _InfoCard(
              title:   'About ASCMA',
              content: 'ASCMA (Anonymous Suggestion & Complaint Management Application) '
                  'is a secure platform that allows users to submit complaints and suggestions '
                  'anonymously. Your identity is NEVER stored or linked to your submission.',
            ),

            const SizedBox(height: 16),

            _InfoCard(
              title:   'How It Works',
              content: '1. Submit a complaint or suggestion — anonymously.\n'
                  '2. Receive a unique Tracking ID.\n'
                  '3. Track your submission status anytime.\n'
                  '4. Get an official response from the department.',
            ),

            const SizedBox(height: 16),

            _InfoCard(
              title:   'Privacy Policy',
              content: 'We are committed to your privacy:\n'
                  '• No personal data is stored for anonymous submissions.\n'
                  '• All data is encrypted and securely stored.\n'
                  '• Submissions are only accessible to authorized admins.\n'
                  '• You may delete your submissions at any time.',
            ),

            const SizedBox(height: 24),

            const PrivacyBadge(),

            const SizedBox(height: 20),

            Text(
              AppConstants.copyright,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color:    AppColors.textGrey,
                height:   1.7,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize:   15,
              color:      AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color:    AppColors.textDark,
              height:   1.6,
            ),
          ),
        ],
      ),
    );
  }
}
