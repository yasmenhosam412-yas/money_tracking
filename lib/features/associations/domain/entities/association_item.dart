class AssociationItem {
  final String id;
  final String name;
  final bool isPersonal;
  final String role;

  const AssociationItem({
    required this.id,
    required this.name,
    required this.isPersonal,
    required this.role,
  });

  /// Single treasurer: only the owner records income, expenses, plans, and dates.
  bool get isTreasurer => !isPersonal && role == 'owner';

  bool get isMemberViewOnly => !isPersonal && role == 'member';

  /// Personal ledger = you; shared ledger = owner only.
  bool get canEditLedger => isPersonal || isTreasurer;

  bool get canManageInvites =>
      !isPersonal && (role == 'owner' || role == 'admin');
}
