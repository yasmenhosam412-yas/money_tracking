import 'package:flutter/material.dart';

/// Icon and accent color for a payment / income source label.
class PaymentMethodVisual {
  const PaymentMethodVisual({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

/// Maps stored source names (English presets or custom) to a recognizable icon.
PaymentMethodVisual? paymentMethodVisualFor(String? stored) {
  if (stored == null || stored.trim().isEmpty) return null;

  final n = stored.trim().toLowerCase();

  if (n.contains('vodafone') || n.contains('فودافون')) {
    return const PaymentMethodVisual(
      icon: Icons.phone_android_rounded,
      color: Color(0xFFE60000),
    );
  }
  if (n.contains('instapay') || n.contains('إنستا') || n.contains('انستا')) {
    return const PaymentMethodVisual(
      icon: Icons.flash_on_rounded,
      color: Color(0xFF6C3FC5),
    );
  }
  if (n.contains('fawry') || n.contains('فوري')) {
    return const PaymentMethodVisual(
      icon: Icons.storefront_rounded,
      color: Color(0xFFF5B800),
    );
  }
  if (n.contains('visa') || n.contains('فيزا') || n.contains('master')) {
    return const PaymentMethodVisual(
      icon: Icons.credit_card_rounded,
      color: Color(0xFF1A1F71),
    );
  }
  if (n == 'cash' || n.contains('كاش') || n.contains('نقد')) {
    return const PaymentMethodVisual(
      icon: Icons.payments_rounded,
      color: Color(0xFF2E7D32),
    );
  }
  if (n.contains('bank') || n.contains('transfer') || n.contains('تحويل')) {
    return const PaymentMethodVisual(
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1565C0),
    );
  }
  if (n.contains('wallet') || n.contains('محفظ')) {
    return const PaymentMethodVisual(
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF00838F),
    );
  }

  return const PaymentMethodVisual(
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF757575),
  );
}
