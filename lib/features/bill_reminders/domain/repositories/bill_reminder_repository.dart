import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/bill_reminders/domain/entities/bill_reminder.dart';

abstract class BillReminderRepository {
  Future<Either<Failure, List<BillReminder>>> getAll();

  Future<Either<Failure, BillReminder>> save(BillReminder reminder);

  Future<Either<Failure, void>> delete(String id);
}
