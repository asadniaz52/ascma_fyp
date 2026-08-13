// ─── Submit Suggestion Screen ──────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import 'complaint_submitted_screen.dart';

class SubmitSuggestionScreen extends StatefulWidget {
  const SubmitSuggestionScreen({super.key});

  @override
  State<SubmitSuggestionScreen> createState() => _SubmitSuggestionScreenState();
}

class _SubmitSuggestionScreenState extends State<SubmitSuggestionScreen> {
  String?     _selectedCategory;
  final _descCtrl = TextEditingController();
  File?       _imageFile;
  bool        _isSubmitting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      _showSnack('Please select a suggestion category', isError: true);
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      _showSnack('Please describe your suggestion', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final authService      = context.read<AuthService>();
    final complaintService = context.read<ComplaintService>();
    final user             = authService.currentUser;

    final trackingId = await complaintService.submitComplaint(
      userId:      user?.uid ?? AppConstants.anonymousId,
      userName:    user?.name,
      description: _descCtrl.text.trim(),
      category:    _selectedCategory!,
      type:        'suggestion',
      department:  'Administration',
      isAnonymous: user == null,
      imageFile:   _imageFile,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (trackingId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ComplaintSubmittedScreen(
            trackingId: trackingId,
            type:       'suggestion',
          ),
        ),
      );
    } else {
      _showSnack('Failed to submit suggestion. Please try again.', isError: true);
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

              if (_selectedCategory == null) ...[
                CategoryGrid(
                  categories:  AppConstants.suggestionCategories,
                  headerTitle: 'Suggestion Categories',
                  headerColor: AppColors.greenCard,
                  onSelected:  (cat) => setState(() => _selectedCategory = cat),
                ),
              ] else ...[
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin:  const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:        AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: const Color(0xFFCFD8DC)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _selectedCategory!,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize:   15,
                              color:      AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategory = null),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color:        AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: const Color(0xFFCFD8DC)),
                  ),
                  child: TextField(
                    controller: _descCtrl,
                    maxLines:   6,
                    maxLength:  500,
                    onChanged:  (_) => setState(() {}),
                    style:      GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText:       'Briefly describe your suggestion',
                      hintStyle:      GoogleFonts.poppins(
                          color: AppColors.textGrey, fontSize: 13),
                      border:         InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                        Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 4),
                          child: Text(
                            '$currentLength / ${maxLength ?? 500} characters',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textGrey),
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!,
                        height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),

                const SizedBox(height: 12),

                PrimaryButton(
                  text:  '⬆  Upload Image',
                  color: AppColors.primaryDark,
                  onPressed: _pickImage,
                ),

                const SizedBox(height: 12),

                PrimaryButton(
                  text:      'Submit',
                  isLoading: _isSubmitting,
                  color:     const Color(0xFFB0BEC5),
                  onPressed: _submit,
                ),
              ],

              const SizedBox(height: 20),
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
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded),           label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.description_outlined),   label: 'Submit'),
      BottomNavigationBarItem(icon: Icon(Icons.search_rounded),          label: 'Track'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'About'),
    ],
    onTap: (i) { if (i == 0) Navigator.pop(context); },
  );
}
