import 'dart:ui';

/// Palette inspired by [assets/wallet.png] — warm coral, peach, sage, and gold.
class AppColors {
  AppColors._();

  /// Dark charcoal used for outlines and primary text (wallet stitching / lines).
  static const stroke = Color(0xFF3A322E);

  // Brand — wallet body & strap
  static const primary = Color(0xFFF28C74);
  static const primaryLight = Color(0xFFF9A890);
  static const secondary = Color(0xFFF6A060);

  // Surfaces — warm off-white canvas
  static const background = Color(0xFFFFFDFB);
  static const scaffold = Color(0xFFF7F3EF);
  static const surface = Color(0xFFF0EBE6);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8DED6);

  // Text — charcoal family
  static const textPrimary = stroke;
  static const textSecondary = Color(0xFF6B625C);
  static const textMuted = Color(0xFF9A9089);

  // Tab / semantic — bills (mint), spend (coral), balance (wallet), plans (coins)
  static const income = Color(0xFF7EB87A);
  static const incomeDark = Color(0xFF5A9B56);
  static const incomeLight = Color(0xFFE8F3E6);
  static const incomeBill = Color(0xFFA8D1A0);

  static const expense = Color(0xFFE07A6A);
  static const expenseDark = Color(0xFFC96858);
  static const expenseLight = Color(0xFFFFECE8);

  static const balance = primary;
  static const balanceDark = Color(0xFFE07862);
  static const balanceLight = Color(0xFFFFF0EC);

  static const plans = Color(0xFFF7C14D);
  static const plansDark = Color(0xFFE5A83A);
  static const plansLight = Color(0xFFFFF6DC);

  static const success = income;
  static const warning = plans;
  static const error = expense;

  /// Text/icons on coral or peach fills.
  static const onWarm = Color(0xFFFFFFFF);

  // Legacy aliases
  static const primaryColor = primary;
  static const secondaryColor = primaryLight;
  static const backgroundColor = background;
  static const textColor = textPrimary;
  static const accentColor = warning;
  static const errorColor = error;
}
