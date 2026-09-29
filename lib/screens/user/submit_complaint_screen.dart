// ─── Submit Complaint Screen ───────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/department_model.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../services/department_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import 'complaint_submitted_screen.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  String?          _selectedCategory;
  DepartmentModel? _selectedDepartment;
  String           _selectedPriority = AppConstants.priorityNormal;
  bool             _isAnonymous = true;
  final _descCtrl  = TextEditingController();
  File?            _imageFile;
  bool             _isSubmitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      _showSnack('Please select a complaint category', isError: true);
      return;
    }
    if (_selectedDepartment == null) {
      _showSnack('Please select the target department', isError: true);
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _showSnack('Please describe your complaint', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final authService      = context.read<AuthService>();
    final complaintService = context.read<ComplaintService>();
    final user             = authService.currentUser;

    final trackingId = await complaintService.submitComplaint(
      userId:         user?.uid ?? AppConstants.anonymousId,
      userName:       user?.name,
      studentRegNo:   user?.studentId,
      description:    _descCtrl.text.trim(),
      category:       _selectedCategory!,
      type:           'complaint',
      departmentId:   _selectedDepartment!.departmentId,
      departmentName: _selectedDepartment!.name,
      priority:       _selectedPriority,
      isAnonymous:    _isAnonymous,
      imageFile:      _imageFile,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (trackingId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ComplaintSubmittedScreen(
            trackingId: trackingId,
            type:       'complaint',
          ),
        ),
      );
    } else {
      _showSnack('Failed to submit complaint. Please try again.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: isError ? AppColors.redCard : AppColors.greenCard,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar:          const AscmaAppBar(showMenu: false),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Category Header / Picker ────────────────────────────────────
              if (_selectedCategory == null) ...[
                CategoryGrid(
                  categories:  AppConstants.complaintCategories,
                  headerTitle: 'Select Complaint Category',
                  headerColor: AppColors.redCard,
                  onSelected:  (cat) => setState(() => _selectedCategory = cat),
                ),
              ] else ...[
                // ── Selected Category Header ────────────────────────────────
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  margin:  const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.campaign_rounded, color: AppColors.redCard, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCategory!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize:   14,
                              color:      AppColors.redCard,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),

                // ── Target Department Selection ─────────────────────────────
                Text(
                  'Select Target Department *',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                StreamBuilder<List<DepartmentModel>>(
                  stream: context.read<DepartmentService>().getDepartmentsStream(onlyActive: true),
                  builder: (context, snapshot) {
                    final depts = snapshot.data ?? [];
                    DepartmentModel? currentVal;
                    if (_selectedDepartment != null &&
                        depts.any((d) => d.departmentId == _selectedDepartment!.departmentId)) {
                      currentVal = depts.firstWhere((d) => d.departmentId == _selectedDepartment!.departmentId);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color:        AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: const Color(0xFFCFD8DC)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DepartmentModel>(
                          isExpanded: true,
                          hint: Text(
                            'Choose University Department',
                            style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
                          ),
                          value: currentVal,
                          items: depts.map((d) {
                            return DropdownMenuItem<DepartmentModel>(
                              value: d,
                              child: Text(
                                d.name,
                                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedDepartment = val),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── Description ─────────────────────────────────────────────
                Text(
                  'Complaint Description *',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color:        AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: const Color(0xFFCFD8DC)),
                  ),
                  child: TextField(
                    controller:  _descCtrl,
                    maxLines:    5,
                    maxLength:   500,
                    onChanged:   (_) => setState(() {}),
                    style:       GoogleFonts.poppins(fontSize: 13),
                    decoration:  InputDecoration(
                      hintText:        'Provide detailed facts regarding the issue...',
                      hintStyle:       GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13),
                      border:          InputBorder.none,
                      contentPadding:  const EdgeInsets.all(14),
                      counterStyle:    GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Priority & Anonymity Row ────────────────────────────────
                Row(
                  children: [
                    // Priority selector
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCFD8DC)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPriority,
                            items: AppConstants.priorities.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(
                                  'Priority: $p',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedPriority = v);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Anonymous Toggle Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isAnonymous ? const Color(0xFFE8F5E9) : AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isAnonymous ? AppColors.greenCard : const Color(0xFFCFD8DC),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isAnonymous ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
                              size: 16,
                              color: _isAnonymous ? AppColors.greenCard : AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _isAnonymous ? 'Anonymous' : 'With Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isAnonymous ? AppColors.greenCard : AppColors.primaryBlue,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isAnonymous,
                              activeThumbColor: AppColors.greenCard,
                              onChanged: (v) => setState(() => _isAnonymous = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Upload Image Preview ────────────────────────────────────
                if (_imageFile != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                ],

                PrimaryButton(
                  text:  _imageFile != null ? 'Change Attachment' : '⬆  Attach Supporting Photo',
                  color: AppColors.primaryDark,
                  onPressed: _pickImage,
                ),

                const SizedBox(height: 12),

                PrimaryButton(
                  text:      'Submit Complaint',
                  isLoading: _isSubmitting,
                  color:     AppColors.primaryBlue,
                  onPressed: _submit,
                ),
              ],

              const SizedBox(height: 20),

              // ── Privacy Badge ───────────────────────────────────────────────
              const PrivacyBadge(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }
}

Widget _bottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex:         1,
    type:                 BottomNavigationBarType.fixed,
    selectedItemColor:    AppColors.primaryBlue,
    unselectedItemColor:  AppColors.textGrey,
    selectedLabelStyle:   GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded),           label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.description_outlined),   label: 'Submit'),
      BottomNavigationBarItem(icon: Icon(Icons.search_rounded),          label: 'Track'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'About'),
    ],
    onTap: (i) {
      if (i == 0) Navigator.pop(context);
    },
  );
}
