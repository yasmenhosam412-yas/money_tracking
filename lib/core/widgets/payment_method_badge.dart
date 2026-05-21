import 'package:flutter/material.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/payment_method_visual.dart';

/// Compact chip showing payment source with a colored icon.
class PaymentMethodBadge extends StatelessWidget {
  final String label;
  final String? storedSource;

  const PaymentMethodBadge({
    super.key,
    required this.label,
    this.storedSource,
  });

  @override
  Widget build(BuildContext context) {
    final visual = paymentMethodVisualFor(storedSource ?? label);
    if (visual == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: visual.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visual.icon, size: 14, color: visual.color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor.withValues(alpha: 0.75),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
