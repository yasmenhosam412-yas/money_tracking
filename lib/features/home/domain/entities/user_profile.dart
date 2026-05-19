import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String email;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
  });

  String get displayName =>
      username.trim().isNotEmpty ? username.trim() : _nameFromEmail(email);

  static String _nameFromEmail(String email) {
    if (email.isEmpty) return '';
    final local = email.split('@').first;
    return local.isEmpty ? email : local;
  }

  @override
  List<Object> get props => [id, username, email];
}
