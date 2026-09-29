// ─── Onboarding Screen ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isViewingAgain;
  const OnboardingScreen({super.key, this.isViewingAgain = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': '100% Anonymous & Secure',
      'subtitle': 'Submit complaints and constructive suggestions with complete confidence. Your personal identity remains strictly private.',
      'icon': Icons.security_rounded,
      'accentColor': Color(0xFF1565C0),
    },
    {
      'title': 'Direct Departmental Routing',
      'subtitle': 'Submissions are immediately routed to your selected Department Administration for investigation and prompt resolution.',
      'icon': Icons.account_balance_rounded,
      'accentColor': Color(0xFF00838F),
    },
    {
      'title': 'Live Tracking & Official Replies',
      'subtitle': 'Track the progress of your submission in real time using your unique Tracking ID and view official administrative responses.',
      'icon': Icons.track_changes_rounded,
      'accentColor': Color(0xFF2E7D32),
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasSeenOnboarding, true);

    if (!mounted) return;

    if (widget.isViewingAgain) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isViewingAgain
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final Color color = page['accentColor'] as Color;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Icon Container ────────────────────────────────────
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.1),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 68,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Title ─────────────────────────────────────────────
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Subtitle ──────────────────────────────────────────
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Indicators & Next/Get Started Button ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  PrimaryButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (isLastPage) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
