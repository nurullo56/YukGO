import 'package:flutter/material.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';

extension ThemeExt on BuildContext {
  bool get isDark => UserSession.darkMode.value;

  Color get cardColor =>
      isDark ? const Color(0xFF151B2E) : Colors.white;

  Color get inputColor =>
      isDark ? const Color(0xFF1A2340) : const Color(0xFFF1F5F9);

  Color get borderColor =>
      isDark ? const Color(0xFF1E2740) : const Color(0xFFE2E8F0);

  Color get textPrimary =>
      isDark ? const Color(0xFFE8EEFF) : const Color(0xFF1F2638);

  Color get textMuted =>
      isDark ? const Color(0xFF8896B3) : const Color(0xFF64748B);

  Color get bgColor =>
      isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF7FAFF);

  Color get divColor =>
      isDark ? const Color(0xFF1E2740) : const Color(0xFFF1F5F9);
}
