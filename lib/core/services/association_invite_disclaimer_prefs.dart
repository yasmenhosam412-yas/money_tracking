import 'package:shared_preferences/shared_preferences.dart';

class AssociationInviteDisclaimerPrefs {
  static const _acceptedKey = 'association_invite_disclaimer_accepted';

  Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acceptedKey) ?? false;
  }

  Future<void> setAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedKey, true);
  }
}
