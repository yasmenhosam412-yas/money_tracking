import 'package:imrpo/features/home/data/models/user_profile_model.dart';

abstract class HomeDatasource {
  Future<UserProfileModel> getCurrentUserProfile();

  Future<void> updateUsername(String username);
}
