import 'package:flutter/material.dart';
import 'package:imrpo/core/services/payment_methods_store.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/payment_method_chips_section.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Paid-from chips for plan balance allocations (avoids unassigned spending).
class PlanAllocationPaidFromSection extends StatelessWidget {
  static List<String> get suggestedSources =>
      PaymentMethodsStore.defaultPresets;

  final String selectedSource;
  final ValueChanged<String> onSelected;
  final Color accentColor;
  final String? hint;
  final bool enabled;

  const PlanAllocationPaidFromSection({
    super.key,
    required this.selectedSource,
    required this.onSelected,
    this.accentColor = AppColors.plans,
    this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PaymentMethodChipsSection(
      label: l10n.expensePaidFromField,
      hint: hint ?? l10n.balancePlanAllocationPaidFromHint,
      selected: selectedSource,
      onSelected: onSelected,
      accentColor: accentColor,
      enabled: enabled,
    );
  }
}
