// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Ban đêm (Deep Space) ──
  static const Color bg0   = Color(0xFF07091A);
  static const Color bg1   = Color(0xFF0C1228);
  
  // ── Ban ngày (Sky Blue) ──
  static const Color dayBg0 = Color(0xFF4FAAFF);
  static const Color dayBg1 = Color(0xFF80D0FF);

  // ── Glass ──
  static const Color glass      = Color(0x0EFFFFFF);
  static const Color glassBorder = Color(0x18FFFFFF);

  // ── Accent ──
  static const Color accent      = Color(0xFF5B9FFF);
  static const Color accentLight = Color(0xFF8DBFFF);

  // ── Semantic ──
  static const Color warm    = Color(0xFFFFBD59);
  static const Color rain    = Color(0xFF63B3ED);
  static const Color danger  = Color(0xFFFC8181);

  // ── Text ──
  static const Color text1 = Color(0xFFF7FAFF);
  static const Color text2 = Color(0xFF8EA4CC);
  static const Color text3 = Color(0xFF4A5C82);
}

class AppTheme {
  // Gradient theo điều kiện Ngày/Đêm
  static LinearGradient getScreenGradient(bool isNight) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isNight 
          ? [AppColors.bg0, AppColors.bg1, const Color(0xFF0A1025)]
          : [AppColors.dayBg0, AppColors.dayBg1, const Color(0xFFB3E5FF)],
    );
  }

  static BoxDecoration glassBox() {
    return BoxDecoration(
      color: AppColors.glass,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.glassBorder, width: 1),
    );
  }

  static BoxDecoration glassBoxHighlight() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accent.withValues(alpha: 0.18),
          AppColors.accent.withValues(alpha: 0.06),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.accent.withValues(alpha: 0.45), width: 1),
    );
  }

  static const BorderRadius cardRadius   = BorderRadius.all(Radius.circular(20));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(50));

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg0,
      textTheme: GoogleFonts.nunitoTextTheme().apply(bodyColor: AppColors.text1, displayColor: AppColors.text1),
    );
  }
}
