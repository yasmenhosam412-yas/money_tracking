abstract class AuthDatasource {
  Future<void> signup(String username, String email, String password);

  Future<void> login(String email, String password);
  Future<void> forgetPassword(String email);
  Future<void> verifyOTP(String newPassword, String otp, String email);

  Future<void> logout();

  Future<void> deleteAccount();
}
