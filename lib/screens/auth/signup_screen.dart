// ─── Sign Up Screen ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final error = await authService.signUpWithEmail(
      name:     _nameCtrl.text,
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
    );

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
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text('Account created successfully! Please login.', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.greenCard,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize:   26,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 30),

                // ── Name ──────────────────────────────────────────────────────
                CustomTextField(
                  hint:       'Name',
                  controller: _nameCtrl,
                  validator:  (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),

                const SizedBox(height: 14),

                // ── Email ─────────────────────────────────────────────────────
                CustomTextField(
                  hint:        'Email',
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator:   (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Password ──────────────────────────────────────────────────
                CustomTextField(
                  hint:       'Password',
                  isPassword: true,
                  controller: _passwordCtrl,
                  validator:  (v) {
                    if (v == null || v.trim().isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ── Sign Up Button ────────────────────────────────────────────
                PrimaryButton(
                  text:      'SIGN UP',
                  isLoading: authService.isLoading,
                  onPressed: _signUp,
                ),

                const SizedBox(height: 24),

                // ── Divider ───────────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:    AppColors.textGrey,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Use your email for registration',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:    AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Social Icons (UI Only) ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialBtn(icon: Icons.facebook, color: const Color(0xFF1877F2)),
                    const SizedBox(width: 16),
                    _SocialBtn(icon: Icons.g_mobiledata_rounded, color: const Color(0xFFEA4335)),
                    const SizedBox(width: 16),
                    _SocialBtn(icon: Icons.link_rounded, color: const Color(0xFF0A66C2)),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Already have account ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a Member? ',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize:   13,
                          color:      AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialBtn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  46,
      height: 46,
      decoration: BoxDecoration(
        shape:  BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4)),
        color:  color.withOpacity(0.08),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
