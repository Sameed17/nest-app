import 'user_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    this.token,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? token;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'role': role.name,
      'token': token,
    };
  }

  static AuthUser? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final String? id = json['id'] as String?;
    final String? name = json['name'] as String?;
    final UserRole? role = UserRole.tryParse(json['role'] as String?);
    if (id == null || name == null || role == null) {
      return null;
    }
    final String? token = json['token'] as String?;
    return AuthUser(id: id, name: name, role: role, token: token);
  }
}

