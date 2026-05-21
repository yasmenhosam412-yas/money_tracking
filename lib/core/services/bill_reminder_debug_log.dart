import 'package:flutter/foundation.dart';

/// Debug logging for bill reminder notifications (filter logcat: BillReminder).
void billReminderLog(String message) {
  debugPrint('[BillReminder] $message');
}

void billReminderLogError(String message, [Object? error, StackTrace? stack]) {
  debugPrint('[BillReminder] ERROR: $message');
  if (error != null) {
    debugPrint('[BillReminder]   $error');
  }
  if (stack != null) {
    debugPrint('[BillReminder]   $stack');
  }
}
