import 'package:flutter/material.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/associations/presentation/pages/association_hub_screen.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Banner under home header: treasurer hub or read-only notice.
class AssociationLedgerBanner extends StatelessWidget {
  const AssociationLedgerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: getIt<AssociationContext>(),
      builder: (context, _) {
        final ctx = getIt<AssociationContext>();
        final item = ctx.activeItem;
        if (item == null || item.isPersonal) return const SizedBox.shrink();

        final name = ctx.displayName(
          item,
          personalFallback: l10n.associationPersonal,
        );

        if (item.isTreasurer) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Material(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AssociationHubScreen(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.associationHubBannerTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              l10n.associationHubBannerBody(name),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        l10n.associationHubOpen,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Material(
            color: AppColors.incomeLight,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AssociationHubScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.incomeDark,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.associationMemberReadOnlyBanner(name),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.incomeDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
