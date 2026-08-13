// ─── Welcome Screen ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // ── Shield Logo ────────────────────────────────────────────
                  Container(
                    width:  160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentBlue.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width:  120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape:     BoxShape.circle,
                          gradient:  AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color:      AppColors.primaryBlue.withOpacity(0.4),
                              blurRadius: 24,
                              offset:     const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size:  68,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── App Name ───────────────────────────────────────────────
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.poppins(
                      fontSize:    42,
                      fontWeight:  FontWeight.w900,
                      color:       AppColors.primaryBlue,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tagline ────────────────────────────────────────────────
                  Text(
                    AppConstants.appFullName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize:    14,
                      fontStyle:   FontStyle.italic,
                      color:       AppColors.textGrey,
                      height:      1.5,
                    ),
                  ),

                  const Spacer(),

                  // ── Get Started Button ─────────────────────────────────────
                  PrimaryButton(
                    text:      'Get Started',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Copyright ──────────────────────────────────────────────
                  Text(
                    AppConstants.copyright,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color:    AppColors.textGrey,
                      height:   1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
