// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🌙 BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color inputBg = Color(0xFF0D1420);
  static const Color surfaceDark = Color(0xFF141B2D);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 ACCENT (Gold)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFA000);
  static const Color accentDim = Color(0xFFC5A059);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 TEXT
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDark = Color(0xFF1E293B);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚦 STATUS COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color blue = Color(0xFF3B82F6);
  static const Color green = Color(0xFF22C55E);
  static const Color purple = Color(0xFF9333EA);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color orange = Color(0xFFF97316);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color error = Color(0xFFEF4444);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔲 BORDER
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderLight = Color(0x33FFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌈 GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8F48FF), Color(0xFF722CE8)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardDark, Color(0xFF243045)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌟 SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get whiteGlowShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.08),
      blurRadius: 25,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: accent.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get purpleGlowShadow => [
    BoxShadow(
      color: purple.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}