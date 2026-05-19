import 'package:flutter/material.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/l10n/app_localizations.dart';

Future<void> showHomeDateFilterSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final filter = getIt<HomeDateFilter>();
  var mode = filter.mode;
  var selected = filter.date;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              helpText: mode == HomeDateFilterMode.month
                  ? l10n.homeFilterPickMonth
                  : l10n.homeFilterPickDay,
            );
            if (picked != null) {
              setSheetState(() => selected = picked);
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.homeDateFilterTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 20),
                SegmentedButton<HomeDateFilterMode>(
                  segments: [
                    ButtonSegment(
                      value: HomeDateFilterMode.month,
                      label: Text(l10n.homeFilterByMonth),
                      icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: HomeDateFilterMode.day,
                      label: Text(l10n.homeFilterByDay),
                      icon: const Icon(Icons.today_outlined, size: 18),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (value) {
                    setSheetState(() => mode = value.first);
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: Text(
                    mode == HomeDateFilterMode.month
                        ? l10n.homeFilterPickMonth
                        : l10n.homeFilterPickDay,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setSheetState(() {
                      mode = HomeDateFilterMode.day;
                      selected = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.restore_rounded),
                  label: Text(l10n.homeFilterToday),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          filter.apply(date: selected, mode: mode);
                          Navigator.pop(sheetContext);
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          );
        },
      );
    },
  );
}
