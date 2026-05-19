import 'package:supabase_flutter/supabase_flutter.dart';

/// Guards Supabase calls that require a signed-in user id (UUID).
class SupabaseAuthHelper {
  SupabaseAuthHelper._();

  static String? get userId =>
      Supabase.instance.client.auth.currentUser?.id;

  static bool get isSignedIn {
    final id = userId;
    return id != null && id.isNotEmpty;
  }

  static String requireUserId() {
    final id = userId;
    if (id == null || id.isEmpty) {
      throw const AuthException('Not signed in');
    }
    return id;
  }
}
