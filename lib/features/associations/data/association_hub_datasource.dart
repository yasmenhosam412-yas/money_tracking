import 'package:imrpo/features/associations/domain/entities/association_hub_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssociationHubDatasource {
  final SupabaseClient _client;

  AssociationHubDatasource(this._client);

  Future<AssociationHubData> loadHub(String associationId) async {
    final raw = await _client.rpc(
      'get_association_hub',
      params: {'p_association_id': associationId},
    );
    final map = Map<String, dynamic>.from(raw as Map);
    return _parseHub(map);
  }

  Future<void> saveGom3eya({
    required String associationId,
    required double? payoutAmount,
    required double? installmentAmount,
    required int? collectionDay,
    required List<AssociationTurnSlot> slots,
  }) async {
    final payload = slots
        .map(
          (s) => {
            'slot_index': s.slotIndex,
            'holder_name': s.holderName,
          },
        )
        .toList();

    await _client.rpc(
      'save_association_gom3eya',
      params: {
        'p_association_id': associationId,
        'p_payout_amount': payoutAmount ?? 0,
        'p_installment_amount': installmentAmount ?? 0,
        'p_collection_day': collectionDay,
        'p_slots': payload,
      },
    );
  }

  Future<String> addPayment({
    required String associationId,
    required String payerName,
    required double amount,
    required DateTime paidAt,
    String? turnSlotId,
    String? note,
  }) async {
    final id = await _client.rpc(
      'add_association_payment',
      params: {
        'p_association_id': associationId,
        'p_payer_name': payerName,
        'p_amount': amount,
        'p_paid_at': paidAt.toUtc().toIso8601String(),
        'p_turn_slot_id': turnSlotId,
        'p_note': note,
      },
    );
    return id.toString();
  }

  Future<void> deletePayment(String paymentId) async {
    await _client.rpc(
      'delete_association_payment',
      params: {'p_payment_id': paymentId},
    );
  }

  Future<DateTime> endGom3eya(String associationId) async {
    final raw = await _client.rpc(
      'end_association_gom3eya',
      params: {'p_association_id': associationId},
    );
    return DateTime.parse(raw.toString()).toLocal();
  }

  Future<int> advanceTurn(String associationId) async {
    final next = await _client.rpc(
      'advance_association_turn',
      params: {'p_association_id': associationId},
    );
    return (next as num).toInt();
  }

  AssociationHubData _parseHub(Map<String, dynamic> map) {
    final assoc = Map<String, dynamic>.from(
      map['association'] as Map? ?? {},
    );
    final slotsRaw = map['slots'] as List<dynamic>? ?? [];
    final membersRaw = map['members'] as List<dynamic>? ?? [];
    final paymentsRaw = map['payments'] as List<dynamic>? ?? [];

    final slots = slotsRaw.map((row) {
      final s = Map<String, dynamic>.from(row as Map);
      final received = s['received_at']?.toString();
      return AssociationTurnSlot(
        id: s['id']?.toString(),
        slotIndex: (s['slot_index'] as num?)?.toInt() ?? 0,
        holderName: s['holder_name']?.toString() ?? '',
        userId: s['user_id']?.toString(),
        receivedAt:
            received != null && received.isNotEmpty
                ? DateTime.tryParse(received)
                : null,
      );
    }).toList();

    final members = membersRaw.map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      return AssociationHubMember(
        userId: m['user_id']?.toString() ?? '',
        role: m['role']?.toString() ?? 'member',
        username: m['username']?.toString() ?? '',
      );
    }).toList();

    final payments = paymentsRaw.map((row) {
      final p = Map<String, dynamic>.from(row as Map);
      final paidRaw = p['paid_at']?.toString();
      return AssociationInstallmentPayment(
        id: p['id']?.toString() ?? '',
        payerName: p['payer_name']?.toString() ?? '',
        turnSlotId: p['turn_slot_id']?.toString(),
        amount: _parseAmount(p['amount']) ?? 0,
        paidAt: paidRaw != null && paidRaw.isNotEmpty
            ? DateTime.parse(paidRaw).toLocal()
            : DateTime.now(),
        note: p['note']?.toString(),
      );
    }).toList();

    return AssociationHubData(
      id: assoc['id']?.toString() ?? '',
      name: assoc['name']?.toString() ?? '',
      isPersonal: assoc['is_personal'] == true,
      payoutAmount: _parseAmount(assoc['payout_amount']),
      installmentAmount: _parseAmount(assoc['installment_amount']),
      memberSlots: (assoc['member_slots'] as num?)?.toInt() ?? slots.length,
      currentTurnIndex: (assoc['current_turn_index'] as num?)?.toInt() ?? 0,
      collectionDay: (assoc['collection_day'] as num?)?.toInt(),
      slots: slots,
      members: members,
      payments: payments,
      isOwner: map['is_owner'] == true,
      gom3eyaEndedAt: _parseDateTime(assoc['gom3eya_ended_at']),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s)?.toLocal();
  }

  double? _parseAmount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
