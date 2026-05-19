import 'package:flutter/material.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/widgets/app_lock_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Locks the app when it goes to the background and the user is signed in.
class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = getIt<AppLockService>();
    final isLoggedIn = getIt<SupabaseClient>().auth.currentUser != null;
    if (!lock.shouldGuard(isLoggedIn)) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        lock.lock();
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<AppLockService>(),
      builder: (context, _) {
        final lock = getIt<AppLockService>();
        final isLoggedIn = getIt<SupabaseClient>().auth.currentUser != null;
        final showLock = lock.shouldGuard(isLoggedIn) && lock.isLocked;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (showLock) const Positioned.fill(child: AppLockScreen()),
          ],
        );
      },
    );
  }
}
