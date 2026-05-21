class AssociationInviteItem {
  final String inviteId;
  final String associationId;
  final String associationName;
  final String inviterUsername;
  final DateTime createdAt;
  final DateTime expiresAt;

  const AssociationInviteItem({
    required this.inviteId,
    required this.associationId,
    required this.associationName,
    required this.inviterUsername,
    required this.createdAt,
    required this.expiresAt,
  });
}
