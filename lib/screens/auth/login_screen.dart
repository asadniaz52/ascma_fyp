// ─── Login Screen ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../user/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../super_admin/super_admin_dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool  _rememberMe    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final error = await authService.loginWithEmail(
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      _showError(error);
      return;
    }

    // Navigate based on role
    final user = authService.currentUser;
    if (user == null) return;

    Widget destination;
    if (user.isSuperAdmin) {
      destination = const SuperAdminDashboardScreen();
    } else if (user.isAdmin) {
      destination = const AdminDashboardScreen();
    } else {
      destination = const HomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:          Text(msg, style: GoogleFonts.poppins()),
        backgroundColor:  AppColors.redCard,
        behavior:         SnackBarBehavior.floating,
        shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration:         const Duration(seconds: 3),
      ),
    );
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
                const SizedBox(height: 50),

                // ── User Avatar ───────────────────────────────────────────────
                Container(
                  width:  90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size:  56,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 30),

                // ── Email Field ───────────────────────────────────────────────
                CustomTextField(
                  hint:        'Email',
                  prefixIcon:  Icons.person_outline_rounded,
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator:   (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ── Password Field ────────────────────────────────────────────
                CustomTextField(
                  hint:       'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _passwordCtrl,
                  validator:  (v) {
                    if (v == null || v.trim().isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // ── Remember Me + Forgot Password ─────────────────────────────
                Row(
                  children: [
                    Checkbox(
                      value:    _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      activeColor: AppColors.primaryBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text('Remember me',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:    AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Login Button ──────────────────────────────────────────────
                PrimaryButton(
                  text:      'LOGIN',
                  isLoading: authService.isLoading,
                  onPressed: _login,
                ),

                const SizedBox(height: 20),

                // ── Sign Up Link ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a Member? ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:    AppColors.textGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: Text(
                        'Create an Account',
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
