class AssociationHubData {
  final String id;
  final String name;
  final bool isPersonal;
  final double? payoutAmount;
  final double? installmentAmount;
  final int memberSlots;
  final int currentTurnIndex;
  final int? collectionDay;
  final List<AssociationTurnSlot> slots;
  final List<AssociationHubMember> members;
  final List<AssociationInstallmentPayment> payments;
  final bool isOwner;
  final DateTime? gom3eyaEndedAt;

  const AssociationHubData({
    required this.id,
    required this.name,
    required this.isPersonal,
    this.payoutAmount,
    this.installmentAmount,
    required this.memberSlots,
    required this.currentTurnIndex,
    this.collectionDay,
    required this.slots,
    required this.members,
    required this.payments,
    required this.isOwner,
    this.gom3eyaEndedAt,
  });

  bool get isEnded => gom3eyaEndedAt != null;

  bool get canManage => isOwner && !isEnded;

  double get totalPaid =>
      payments.fold(0.0, (sum, p) => sum + p.amount);

  AssociationTurnSlot? get currentSlot {
    if (slots.isEmpty) return null;
    for (final slot in slots) {
      if (slot.slotIndex == currentTurnIndex) return slot;
    }
    return slots.first;
  }

  int get turnNumber => memberSlots > 0 ? currentTurnIndex + 1 : 0;

  double get computedPayout {
    if (payoutAmount != null && payoutAmount! > 0) return payoutAmount!;
    if (installmentAmount != null &&
        installmentAmount! > 0 &&
        memberSlots > 0) {
      return installmentAmount! * memberSlots;
    }
    return 0;
  }
}

class AssociationTurnSlot {
  final String? id;
  final int slotIndex;
  final String holderName;
  final String? userId;
  final DateTime? receivedAt;

  const AssociationTurnSlot({
    this.id,
    required this.slotIndex,
    required this.holderName,
    this.userId,
    this.receivedAt,
  });

  bool get hasReceived => receivedAt != null;
}

class AssociationInstallmentPayment {
  final String id;
  final String payerName;
  final String? turnSlotId;
  final double amount;
  final DateTime paidAt;
  final String? note;

  const AssociationInstallmentPayment({
    required this.id,
    required this.payerName,
    this.turnSlotId,
    required this.amount,
    required this.paidAt,
    this.note,
  });
}

class AssociationHubMember {
  final String userId;
  final String role;
  final String username;

  const AssociationHubMember({
    required this.userId,
    required this.role,
    required this.username,
  });
}
