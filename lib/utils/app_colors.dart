// ─── App Colors ───────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primaryBlue    = Color(0xFF1565C0);
  static const Color primaryDark    = Color(0xFF0D47A1);
  static const Color primaryLight   = Color(0xFF1976D2);
  static const Color accentBlue     = Color(0xFF2196F3);

  // Status Colors
  static const Color redCard        = Color(0xFFE53935);
  static const Color greenCard      = Color(0xFF43A047);
  static const Color orangeStatus   = Color(0xFFFF8F00);
  static const Color tealHeader     = Color(0xFF00838F);

  // Backgrounds & Borders
  static const Color scaffoldBg     = Color(0xFFF5F6FA);
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color surfaceGrey    = Color(0xFFECEFF1);
  static const Color borderGrey     = Color(0xFFCFD8DC);
  static const Color dividerGrey    = Color(0xFFE0E0E0);

  // Text
  static const Color textDark       = Color(0xFF1A1A2E);
  static const Color textGrey       = Color(0xFF78909C);
  static const Color textWhite      = Color(0xFFFFFFFF);
  static const Color textBlue       = Color(0xFF1565C0);

  // Status Chips
  static const Color pending        = Color(0xFFFF8F00);
  static const Color inProgress     = Color(0xFF1565C0);
  static const Color resolved       = Color(0xFF2E7D32);
  static const Color rejected       = Color(0xFFB71C1C);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient complaintGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient suggestionGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
