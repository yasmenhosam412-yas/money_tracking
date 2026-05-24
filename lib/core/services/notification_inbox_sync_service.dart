import 'package:imrpo/core/services/locale_preferences.dart';
import 'package:imrpo/core/utils/locale_date_format.dart';
import 'package:imrpo/core/utils/network_errors.dart';
import 'package:flutter/foundation.dart';
import 'package:imrpo/core/services/notification_inbox_store.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/notifications/domain/notification_inbox_item.dart';
import 'package:imrpo/features/notifications/domain/notifications_hub_service.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Records bill/digest alerts that have fired so the UI can show unread badges.
class NotificationInboxSyncService {
  final NotificationsHubService _hub = NotificationsHubService();

  Future<void> syncDelivered() async {
    try {
      final store = getIt<NotificationInboxStore>();
      await store.load();

      final locale = getIt<LocalePreferences>().locale;
      await LocaleDateFormat.ensureInitialized(locale.toString());

      final l10n = lookupAppLocalizations(locale);
      final fired = await _hub.loadRecentlyFired(l10n);

      for (final scheduled in fired) {
        await store.upsertDelivered(
          NotificationInboxItem.fromScheduled(scheduled),
        );
      }
    } catch (e, st) {
      if (isNetworkError(e)) return;
      debugPrint('NotificationInboxSyncService failed: $e\n$st');
    }
  }
}
