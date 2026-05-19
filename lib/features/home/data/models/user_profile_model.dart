import 'package:imrpo/features/home/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.email,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }
}
