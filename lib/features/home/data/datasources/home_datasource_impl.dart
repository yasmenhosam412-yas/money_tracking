import 'package:imrpo/features/home/data/datasources/home_datasource.dart';
import 'package:imrpo/features/home/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeDatasourceImpl implements HomeDatasource {
  final SupabaseClient supabaseClient;

  HomeDatasourceImpl({required this.supabaseClient});

  @override
  Future<UserProfileModel> getCurrentUserProfile() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not signed in');
    }

    final row = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row != null) {
      return UserProfileModel.fromMap(row);
    }

    final metadataName = user.userMetadata?['username'];
    return UserProfileModel(
      id: user.id,
      username: metadataName is String ? metadataName : '',
      email: user.email ?? '',
    );
  }

  @override
  Future<void> updateUsername(String username) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not signed in');
    }

    await supabaseClient
        .from('profiles')
        .update({'username': username})
        .eq('id', user.id);

    await supabaseClient.auth.updateUser(
      UserAttributes(data: {'username': username}),
    );
  }
}
