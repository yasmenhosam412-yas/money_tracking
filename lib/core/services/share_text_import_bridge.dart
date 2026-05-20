import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/shared_text_import_store.dart';

/// Reads Android ACTION_SEND text/plain and forwards to [SharedTextImportStore].
class ShareTextImportBridge {
  ShareTextImportBridge._();

  static final ShareTextImportBridge instance = ShareTextImportBridge._();

  static const _methodChannel = MethodChannel('imrpo/share_text');
  static const _eventChannel = EventChannel('imrpo/share_text_events');

  StreamSubscription<dynamic>? _subscription;
  bool _started = false;

  Future<void> startListening() async {
    if (_started || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _started = true;

    await _readInitial();

    _subscription ??= _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is String && event.trim().isNotEmpty) {
          getIt<SharedTextImportStore>().setPending(event);
        }
      },
      onError: (_) {},
    );
  }

  Future<void> pollInitial() => _readInitial();

  Future<void> _readInitial() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final text = await _methodChannel.invokeMethod<String>('getInitialShareText');
      if (text != null && text.trim().isNotEmpty) {
        getIt<SharedTextImportStore>().setPending(text);
      }
    } on PlatformException {
      // Ignore when channel unavailable (e.g. tests).
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}
