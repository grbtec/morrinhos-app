import 'package:gbt_identity/user.dart';

class AuthenticatedUser extends User {
  final String? givenName;
  final String? familyName;
  final String? email;

  String? get fullName => familyName == null
      ? givenName
      : givenName == null
          ? familyName
          : "$givenName $familyName";

  const AuthenticatedUser({
    required super.id,
    required this.givenName,
    required this.familyName,
    required this.email,
  });

  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    final user = User.fromJson(json);
    return AuthenticatedUser(
      id: user.id,
      givenName:
          (json["given_name"] ?? json["first_name"] ?? json["name"]) as String?,
      familyName: (json["family_name"] ?? json["surname"]) as String?,
      email: (json["email"]) as String?,
    );
  }
}
