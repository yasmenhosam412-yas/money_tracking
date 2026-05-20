import 'package:flutter/material.dart';
import 'package:imrpo/core/config/app_router.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/share_text_import_bridge.dart';
import 'package:imrpo/core/services/shared_text_import_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Opens Smart import when the user shares SMS text into Pocketly.
class SharedTextImportGate extends StatefulWidget {
  final Widget child;

  const SharedTextImportGate({super.key, required this.child});

  @override
  State<SharedTextImportGate> createState() => _SharedTextImportGateState();
}

class _SharedTextImportGateState extends State<SharedTextImportGate>
    with WidgetsBindingObserver {
  bool _openingSmartImport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIt<SharedTextImportStore>().addListener(_onPendingShare);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onResume());
  }

  @override
  void dispose() {
    getIt<SharedTextImportStore>().removeListener(_onPendingShare);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    }
  }

  Future<void> _onResume() async {
    await ShareTextImportBridge.instance.pollInitial();
    _onPendingShare();
  }

  void _onPendingShare() {
    if (!mounted) return;
    final store = getIt<SharedTextImportStore>();
    if (!store.hasPending) return;
    if (Supabase.instance.client.auth.currentUser == null) return;

    final lock = getIt<AppLockService>();
    if (lock.isEnabled && lock.isLocked) return;

    if (store.smartImportScreenOpen || _openingSmartImport) return;

    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    _openingSmartImport = true;
    nav.pushNamed(AppRoutes.smartImport).whenComplete(() {
      _openingSmartImport = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
