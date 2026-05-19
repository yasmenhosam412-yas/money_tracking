import 'dart:ui';

/// Central color palette for the app.
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF3B82F6);
  static const secondary = Color(0xFF0EA5E9);

  // Surfaces
  static const background = Color(0xFFFFFFFF);
  static const scaffold = Color(0xFFF8FAFC);
  static const surface = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  // Tab / semantic
  static const income = Color(0xFF10B981);
  static const incomeDark = Color(0xFF059669);
  static const incomeLight = Color(0xFFD1FAE5);

  static const expense = Color(0xFFEF4444);
  static const expenseDark = Color(0xFFDC2626);
  static const expenseLight = Color(0xFFFEE2E2);

  static const balance = Color(0xFF8B5CF6);
  static const balanceDark = Color(0xFF7C3AED);
  static const balanceLight = Color(0xFFEDE9FE);

  static const plans = Color(0xFF6366F1);
  static const plansDark = Color(0xFF4F46E5);
  static const plansLight = Color(0xFFE0E7FF);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Legacy aliases
  static const primaryColor = primary;
  static const secondaryColor = primaryLight;
  static const backgroundColor = background;
  static const textColor = textPrimary;
  static const accentColor = warning;
  static const errorColor = error;
}
