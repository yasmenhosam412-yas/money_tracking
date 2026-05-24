import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:imrpo/features/notifications/domain/notification_inbox_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationInboxStore extends ChangeNotifier {
  static const _storageKey = 'notification_inbox_v1';
  static const _maxItems = 50;

  List<NotificationInboxItem> _items = [];
  bool _loaded = false;

  List<NotificationInboxItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((i) => i.isUnread).length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _items = [];
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => NotificationInboxItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      } catch (_) {
        _items = [];
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> upsertDelivered(NotificationInboxItem item) async {
    if (!_loaded) await load();
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      final existing = _items[index];
      if (!existing.isUnread) {
        _items[index] = NotificationInboxItem(
          id: item.id,
          kind: item.kind,
          scheduledAt: item.scheduledAt,
          title: item.title,
          subtitle: item.subtitle,
          description: item.description,
          readAt: existing.readAt,
        );
      }
    } else {
      _items.insert(0, item);
      if (_items.length > _maxItems) {
        _items = _items.sublist(0, _maxItems);
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    if (!_loaded) await load();
    if (unreadCount == 0) return;
    _items = _items.map((i) => i.isUnread ? i.markRead() : i).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = [];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
