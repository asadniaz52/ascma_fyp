// ─── Forgot Password Screen ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final error = await authService.sendPasswordReset(_emailCtrl.text);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(error, style: GoogleFonts.poppins()),
          backgroundColor: AppColors.redCard,
          behavior:        SnackBarBehavior.floating,
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(
            'Reset link sent! Check your inbox.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.greenCard,
          behavior:        SnackBarBehavior.floating,
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Back Button ───────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Lock Icon ─────────────────────────────────────────────────
                Container(
                  width:  90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size:  50,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Forgot Password',
                  style: GoogleFonts.poppins(
                    fontSize:   26,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Please enter your email to reset the password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:    AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Email Field ───────────────────────────────────────────────
                CustomTextField(
                  hint:        'Enter your Email',
                  prefixIcon:  Icons.email_outlined,
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator:   (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ── Reset Button ──────────────────────────────────────────────
                PrimaryButton(
                  text:      'Reset Password',
                  isLoading: authService.isLoading,
                  onPressed: _resetPassword,
                  color:     AppColors.primaryLight,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
