import 'package:flutter/material.dart';

class Space {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

class RadiusTokens {
  static const double field = 8.0;
  static const double card = 12.0;
  static const double sheet = 16.0;
  static const double dialog = 28.0;
  static const double pill = 999.0;
}

class MotionTokens {
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration screen = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeOutCubic;
}

class ColorTokens {
  // تباين مفحوص ومعتمد وفق معايير WCAG AA
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF283447);
  static const Color darkBorder = Color(0xFF334155);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // نصوص بتباين مرتفع
  static const Color textHigh = Color(0xFFF8FAFC);   // 13.98:1
  static const Color textMedium = Color(0xFFCBD5E1); // 9.85:1
  static const Color textMuted = Color(0xFF94A3B8);  // 5.71:1

  static const Color primary = Color(0xFF4F46E5);    // 6.29:1
  static const Color accent = Color(0xFF047857);     // 5.48:1
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);
}

class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 26,
    height: 1.46,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.62,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.57,
    letterSpacing: 0,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.57,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.66,
    letterSpacing: 0,
  );

  static const TextStyle questionPrompt = TextStyle(
    fontSize: 18,
    height: 1.6,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
}
