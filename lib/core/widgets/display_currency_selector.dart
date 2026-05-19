import 'package:flutter/material.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/session/user_session.dart';
import 'package:imrpo/core/utils/app_colors.dart';

/// Compact dropdown for app-wide display currency (lists & summaries).
class DisplayCurrencySelector extends StatelessWidget {
  final bool lightStyle;

  const DisplayCurrencySelector({super.key, this.lightStyle = false});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<CurrencyPreferences>();

    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) {
        final labelColor = lightStyle ? Colors.white : AppColors.textPrimary;
        final iconColor = lightStyle
            ? Colors.white.withValues(alpha: 0.9)
            : AppColors.textSecondary;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: lightStyle
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: lightStyle ? null : Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: prefs.displayCode,
              isDense: true,
              dropdownColor: Colors.white,
              icon: Icon(Icons.expand_more_rounded, size: 18, color: iconColor),
              selectedItemBuilder: (context) {
                return CurrencyConverter.currencies.map((c) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${c.code} ${c.symbol}',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList();
              },
              items: CurrencyConverter.currencies.map((c) {
                return DropdownMenuItem(
                  value: c.code,
                  child: Text(
                    '${c.code} ${c.symbol}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (code) {
                if (code == null || code == prefs.displayCode) return;
                prefs.displayCode = code;
                UserSession.refreshForDisplayCurrency(context);
              },
            ),
          ),
        );
      },
    );
  }
}
