// ─── Sign Up Screen ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/department_model.dart';
import '../../services/auth_service.dart';
import '../../services/department_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _studentIdCtrl  = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _phoneCtrl      = TextEditingController();

  DepartmentModel? _selectedDepartment;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('Please select your department', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.redCard,
          behavior:        SnackBarBehavior.floating,
          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final error = await authService.signUpWithEmail(
      name:           _nameCtrl.text.trim(),
      studentId:      _studentIdCtrl.text.trim(),
      email:          _emailCtrl.text.trim(),
      password:       _passwordCtrl.text.trim(),
      departmentId:   _selectedDepartment!.departmentId,
      departmentName: _selectedDepartment!.name,
      phone:          _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
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
                const SizedBox(height: 36),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Student Registration',
                  style: GoogleFonts.poppins(
                    fontSize:   24,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your secure student account',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:    AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Name ──────────────────────────────────────────────────────
                CustomTextField(
                  hint:       'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameCtrl,
                  validator:  (v) =>
                      v == null || v.trim().isEmpty ? 'Full name is required' : null,
                ),

                const SizedBox(height: 12),

                // ── Student ID / Reg No ───────────────────────────────────────
                CustomTextField(
                  hint:       'Student ID / Registration No (e.g. 2021-CS-101)',
                  prefixIcon: Icons.badge_outlined,
                  controller: _studentIdCtrl,
                  validator:  (v) =>
                      v == null || v.trim().isEmpty ? 'Student ID / Reg No is required' : null,
                ),

                const SizedBox(height: 12),

                // ── Department Dropdown ───────────────────────────────────────
                StreamBuilder<List<DepartmentModel>>(
                  stream: context.read<DepartmentService>().getDepartmentsStream(onlyActive: true),
                  builder: (context, snapshot) {
                    final departments = snapshot.data ?? [];
                    DepartmentModel? currentVal;
                    if (_selectedDepartment != null &&
                        departments.any((d) => d.departmentId == _selectedDepartment!.departmentId)) {
                      currentVal = departments.firstWhere((d) => d.departmentId == _selectedDepartment!.departmentId);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color:        AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: const Color(0xFFCFD8DC)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: DropdownButtonFormField<DepartmentModel>(
                        decoration: const InputDecoration(
                          border:     InputBorder.none,
                          prefixIcon: Icon(Icons.school_outlined, color: AppColors.primaryBlue, size: 20),
                        ),
                        isExpanded: true,
                        hint: Text(
                          'Select Department (Mandatory)',
                          style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
                        ),
                        initialValue: currentVal,
                        items: departments.map((d) {
                          return DropdownMenuItem<DepartmentModel>(
                            value: d,
                            child: Text(
                              d.name,
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedDepartment = val);
                        },
                        validator: (v) => v == null ? 'Please select a department' : null,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // ── Email ─────────────────────────────────────────────────────
                CustomTextField(
                  hint:        'University / Personal Email',
                  prefixIcon:  Icons.email_outlined,
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator:   (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ── Password ──────────────────────────────────────────────────
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

                const SizedBox(height: 12),

                // ── Phone (Optional) ──────────────────────────────────────────
                CustomTextField(
                  hint:        'Phone Number (Optional)',
                  prefixIcon:  Icons.phone_outlined,
                  controller:  _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),

                // ── Sign Up Button ────────────────────────────────────────────
                PrimaryButton(
                  text:      'REGISTER AS STUDENT',
                  isLoading: authService.isLoading,
                  onPressed: _signUp,
                ),

                const SizedBox(height: 20),

                // ── Already have account ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already registered? ',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize:   13,
                          color:      AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

