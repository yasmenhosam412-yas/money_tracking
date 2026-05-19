import 'package:imrpo/core/l10n/l10n_error_tokens.dart';
import 'package:imrpo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final SupabaseClient supabaseClient;

  AuthDatasourceImpl({required this.supabaseClient});
  @override
  Future<void> forgetPassword(String email) async {
    await supabaseClient.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  @override
  Future<void> login(String email, String password) async {
    await supabaseClient.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  @override
  Future<void> signup(String username, String email, String password) async {
    final response = await supabaseClient.auth.signUp(
      password: password,
      email: email,
      data: {"username": username},
    );
    final user = response.user;
    if (user != null) {
      await supabaseClient.from("profiles").insert({
        "id": user.id,
        "username": username,
        "email": email,
      });
    }
  }

  @override
  Future<void> verifyOTP(String newPassword, String otp, String email) async {
    await supabaseClient.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.email,
    );
    await supabaseClient.auth.updateUser(UserAttributes(password: newPassword));
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not signed in');
    }

    try {
      await supabaseClient.rpc('delete_account');
    } on PostgrestException catch (e) {
      if (!_isMissingRpc(e)) {
        rethrow;
      }
      throw PostgrestException(
        message: l10nDeleteAccountRpcRequiredToken,
        code: 'PGRST202',
      );
    }

    try {
      await supabaseClient.auth.signOut();
    } catch (_) {}
  }

  bool _isMissingRpc(PostgrestException e) {
    final message = e.message.toLowerCase();
    return e.code == 'PGRST202' ||
        message.contains('could not find the function') ||
        message.contains('delete_account');
  }
}
