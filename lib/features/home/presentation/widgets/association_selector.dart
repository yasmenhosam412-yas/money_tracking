import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/session/user_session.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/association_invites/data/association_invite_datasource.dart';
import 'package:imrpo/features/association_invites/domain/entities/association_invite_item.dart';
import 'package:imrpo/features/association_invites/presentation/pages/invite_members_screen.dart';
import 'package:imrpo/features/associations/presentation/pages/association_hub_screen.dart';
import 'package:imrpo/features/associations/domain/entities/association_item.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Header chip to switch the active association (ledger).
class AssociationSelector extends StatelessWidget {
  const AssociationSelector({
    super.key,
    this.lightStyle = true,
  });

  final bool lightStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ctx = getIt<AssociationContext>();

    return ListenableBuilder(
      listenable: ctx,
      builder: (context, _) {
        if (!SupabaseAuthHelper.isSignedIn) {
          return const SizedBox.shrink();
        }
        if (ctx.isLoaded && !ctx.isAvailable) {
          return const SizedBox.shrink();
        }

        final active = ctx.activeItem;
        final label = active != null
            ? ctx.displayName(
                active,
                personalFallback: l10n.associationPersonal,
              )
            : l10n.associationPersonal;

        return _HeaderActionChip(
          lightStyle: lightStyle,
          icon: Icons.groups_rounded,
          label: label,
          trailingIcon: Icons.expand_more_rounded,
          isHighlighted: active != null && !active.isPersonal,
          onTap: () => _openSheet(context, ctx, l10n),
        );
      },
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    AssociationContext associationContext,
    AppLocalizations l10n,
  ) async {
    if (!associationContext.isLoaded) {
      await associationContext.load();
      if (!context.mounted) return;
    }

    final choice = await showModalBottomSheet<_AssociationSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _AssociationPickerSheet(
        associationContext: associationContext,
        l10n: l10n,
      ),
    );

    if (!context.mounted || choice == null) return;

    if (choice.createRequested) {
      await _createAssociation(context, associationContext, l10n);
      return;
    }

    if (choice.deleteId != null) {
      await _deleteAssociation(
        context,
        associationContext,
        l10n,
        choice.deleteId!,
      );
      return;
    }

    if (choice.selectedId != null &&
        choice.selectedId != associationContext.activeAssociationId) {
      await associationContext.selectAssociation(choice.selectedId!);
      if (!context.mounted) return;
      UserSession.reloadForAssociationSwitch(context);
    }
  }

  Future<void> _createAssociation(
    BuildContext context,
    AssociationContext associationContext,
    AppLocalizations l10n,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _CreateAssociationDialog(l10n: l10n),
    );

    if (!context.mounted || name == null) return;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.associationNameRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await associationContext.createAssociation(name);
      if (!context.mounted) return;
      UserSession.reloadForAssociationSwitch(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.associationCreated(name)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AssociationHubScreen(),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteAssociation(
    BuildContext context,
    AssociationContext associationContext,
    AppLocalizations l10n,
    String associationId,
  ) async {
    AssociationItem? item;
    for (final candidate in associationContext.items) {
      if (candidate.id == associationId) {
        item = candidate;
        break;
      }
    }
    if (item == null) return;

    if (item.isPersonal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.associationCannotDeletePersonal),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await associationContext.deleteAssociation(associationId);
      if (!context.mounted) return;
      UserSession.reloadForAssociationSwitch(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.associationDeletedSnack),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PostgrestException catch (e) {
      if (!context.mounted) return;
      final message = e.message.contains('Cannot delete personal')
          ? l10n.associationCannotDeletePersonal
          : localizeApiError(l10n, e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizeApiError(l10n, e.toString())),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CreateAssociationDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _CreateAssociationDialog({required this.l10n});

  @override
  State<_CreateAssociationDialog> createState() =>
      _CreateAssociationDialogState();
}

class _CreateAssociationDialogState extends State<_CreateAssociationDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _nameController.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.associationCreateTitle),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: l10n.associationNameHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.associationCreateAction),
        ),
      ],
    );
  }
}

class _AssociationSheetResult {
  final String? selectedId;
  final bool createRequested;
  final String? deleteId;

  const _AssociationSheetResult({
    this.selectedId,
    this.createRequested = false,
    this.deleteId,
  });
}

class _AssociationPickerSheet extends StatefulWidget {
  final AssociationContext associationContext;
  final AppLocalizations l10n;

  const _AssociationPickerSheet({
    required this.associationContext,
    required this.l10n,
  });

  @override
  State<_AssociationPickerSheet> createState() => _AssociationPickerSheetState();
}

class _AssociationPickerSheetState extends State<_AssociationPickerSheet> {
  final _inviteDs = AssociationInviteDatasource(getIt<SupabaseClient>());
  List<AssociationInviteItem> _pendingInvites = [];
  bool _loadingInvites = true;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    try {
      final list = await _inviteDs.listMyPendingInvites();
      if (!mounted) return;
      setState(() {
        _pendingInvites = list;
        _loadingInvites = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingInvites = false);
    }
  }

  Future<void> _respondInvite(AssociationInviteItem invite, bool accept) async {
    final l10n = widget.l10n;
    try {
      await _inviteDs.respondInvite(inviteId: invite.inviteId, accept: accept);
      if (!mounted) return;
      await widget.associationContext.load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? l10n.associationInviteAcceptedSnack
                : l10n.associationInviteRejectedSnack,
          ),
        ),
      );
      await _loadInvites();
      if (accept && mounted) {
        await widget.associationContext.selectAssociation(invite.associationId);
        if (mounted) {
          UserSession.reloadForAssociationSwitch(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizeApiError(l10n, e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openAssociationHub() {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AssociationHubScreen(),
      ),
    );
  }

  void _openInviteMembers(AssociationItem item) {
    final name = widget.associationContext.displayName(
      item,
      personalFallback: widget.l10n.associationPersonal,
    );
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InviteMembersScreen(
          associationId: item.id,
          associationName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final activeId = widget.associationContext.activeAssociationId;
    final items = widget.associationContext.items;
    final activeItem = widget.associationContext.activeItem;

    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
              const SizedBox(height: 16),
              Text(
                l10n.associationPickerTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.associationPickerSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
            if (_loadingInvites)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_pendingInvites.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.associationInvitePendingTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ..._pendingInvites.map((invite) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          invite.associationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invite.inviterUsername,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _respondInvite(invite, false),
                                child: Text(l10n.associationInviteReject),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    _respondInvite(invite, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: Text(l10n.associationInviteAccept),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            ...items.map((item) {
              final selected = item.id == activeId;
              final label = widget.associationContext.displayName(
                item,
                personalFallback: l10n.associationPersonal,
              );
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.isPersonal
                      ? Icons.person_outline_rounded
                      : Icons.groups_rounded,
                  color: selected ? AppColors.primary : AppColors.textColor,
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!item.isPersonal)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.errorColor,
                          size: 22,
                        ),
                        tooltip: l10n.associationDeleteAction,
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(l10n.associationDeleteConfirmTitle),
                              content: Text(
                                l10n.associationDeleteConfirmMessage(label),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, true),
                                  child: Text(l10n.associationDeleteAction),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            Navigator.pop(
                              context,
                              _AssociationSheetResult(deleteId: item.id),
                            );
                          }
                        },
                      ),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      ),
                  ],
                ),
                onTap: () => Navigator.pop(
                  context,
                  _AssociationSheetResult(selectedId: item.id),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (activeItem != null && !activeItem.isPersonal) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.groups_3_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  l10n.associationHubTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onTap: _openAssociationHub,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  l10n.associationInviteMembersAction,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () => _openInviteMembers(activeItem),
              ),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary),
              title: Text(
                l10n.associationCreateAction,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              onTap: () => Navigator.pop(
                context,
                const _AssociationSheetResult(createRequested: true),
              ),
            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mirrors home header chip styling (defined in home_screen.dart).
class _HeaderActionChip extends StatelessWidget {
  final bool lightStyle;
  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _HeaderActionChip({
    required this.lightStyle,
    required this.icon,
    required this.label,
    this.trailingIcon,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = lightStyle
        ? Colors.white.withValues(alpha: isHighlighted ? 0.28 : 0.18)
        : AppColors.surface;
    final fg = lightStyle ? Colors.white : AppColors.textColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: lightStyle
                ? Border.all(color: Colors.white.withValues(alpha: 0.25))
                : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 4),
                Icon(trailingIcon, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
