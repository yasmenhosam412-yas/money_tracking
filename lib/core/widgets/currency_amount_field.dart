import 'package:flutter/material.dart';
import 'package:imrpo/core/models/currency.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class CurrencyAmountField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color accentColor;
  final ValueChanged<Currency>? onCurrencyChanged;
  final String? initialCurrencyCode;

  const CurrencyAmountField({
    super.key,
    required this.label,
    required this.controller,
    required this.accentColor,
    this.onCurrencyChanged,
    this.initialCurrencyCode,
  });

  @override
  State<CurrencyAmountField> createState() => _CurrencyAmountFieldState();
}

class _CurrencyAmountFieldState extends State<CurrencyAmountField> {
  late Currency _selected;

  @override
  void initState() {
    super.initState();
    _selected = CurrencyConverter.byCode(
      widget.initialCurrencyCode ?? CurrencyConverter.defaultDisplayCode,
    );
    widget.controller.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAmountChanged);
    super.dispose();
  }

  void _onAmountChanged() => setState(() {});

  Currency get selectedCurrency => _selected;

  double? get enteredAmount => double.tryParse(widget.controller.text.trim());

  /// Amount converted to app base (USD) for storage.
  double? get amountInBase {
    final amount = enteredAmount;
    if (amount == null) return null;
    return CurrencyConverter.toBase(amount, _selected.code);
  }

  @override
  Widget build(BuildContext context) {
    final amount = enteredAmount;
    final showConversion =
        amount != null && amount > 0 && _selected.code != CurrencyConverter.baseCode;
    final showSameBase =
        amount != null && amount > 0 && _selected.code == CurrencyConverter.baseCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CurrencySelector(
              selected: _selected,
              accentColor: widget.accentColor,
              onChanged: (currency) {
                setState(() => _selected = currency);
                widget.onCurrencyChanged?.call(currency);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: widget.accentColor, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showConversion || showSameBase) ...[
          const SizedBox(height: 10),
          _ConversionBanner(
            accentColor: widget.accentColor,
            fromAmount: amount,
            fromCode: _selected.code,
          ),
        ],
      ],
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final Currency selected;
  final Color accentColor;
  final ValueChanged<Currency> onChanged;

  const _CurrencySelector({
    required this.selected,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.code,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(Icons.expand_more_rounded, color: accentColor),
          items: CurrencyConverter.currencies.map((currency) {
            return DropdownMenuItem(
              value: currency.code,
              child: Text(
                currency.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: (code) {
            if (code == null) return;
            onChanged(CurrencyConverter.byCode(code));
          },
        ),
      ),
    );
  }
}

class _ConversionBanner extends StatelessWidget {
  final double fromAmount;
  final String fromCode;
  final Color accentColor;

  const _ConversionBanner({
    required this.fromAmount,
    required this.fromCode,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final inBase = CurrencyConverter.toBase(fromAmount, fromCode);
    final base = CurrencyConverter.base;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.currency_exchange_rounded, size: 20, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CurrencyConverter.format(fromAmount, fromCode)} = '
                  '${CurrencyConverter.format(inBase, base.code)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.storedAsBase(
                    CurrencyConverter.format(inBase, base.code),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
