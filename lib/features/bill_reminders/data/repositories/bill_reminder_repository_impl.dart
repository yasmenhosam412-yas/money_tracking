import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/bill_reminder_debug_log.dart';
import 'package:imrpo/core/services/bill_reminder_notification_service.dart';
import 'package:imrpo/features/bill_reminders/data/bill_reminder_store.dart';
import 'package:imrpo/features/bill_reminders/domain/entities/bill_reminder.dart';
import 'package:imrpo/features/bill_reminders/domain/repositories/bill_reminder_repository.dart';

class BillReminderRepositoryImpl implements BillReminderRepository {
  final BillReminderStore store;

  BillReminderRepositoryImpl({required this.store});

  Future<List<BillReminder>> _loadAndSync() async {
    final userId = SupabaseAuthHelper.requireUserId();
    return store.loadAll(userId);
  }

  Future<void> _persistAndSchedule(List<BillReminder> reminders) async {
    final userId = SupabaseAuthHelper.requireUserId();
    billReminderLog('repo: save ${reminders.length} reminder(s) user=$userId');
    await store.saveAll(userId, reminders);
    await BillReminderNotificationService.instance.rescheduleAll(reminders);
  }

  @override
  Future<Either<Failure, List<BillReminder>>> getAll() async {
    try {
      if (!SupabaseAuthHelper.isSignedIn) {
        return const Right([]);
      }
      return Right(await _loadAndSync());
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, BillReminder>> save(BillReminder reminder) async {
    try {
      final list = await _loadAndSync();
      final index = list.indexWhere((r) => r.id == reminder.id);
      final updated = List<BillReminder>.from(list);
      if (index >= 0) {
        updated[index] = reminder;
      } else {
        updated.add(reminder);
      }
      await _persistAndSchedule(updated);
      return Right(reminder);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final list = await _loadAndSync();
      final updated = list.where((r) => r.id != id).toList();
      await BillReminderNotificationService.instance.cancelReminder(id);
      await _persistAndSchedule(updated);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
