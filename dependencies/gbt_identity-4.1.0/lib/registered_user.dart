import 'package:gbt_identity/authenticated_user.dart';

class RegisteredUser extends AuthenticatedUser {
  @override
  String get givenName => super.givenName!;

  @override
  String get email => super.email!;

  final String? picture;

  const RegisteredUser({
    required super.id,
    required String givenName,
    required String? familyName,
    required String email,
    required this.picture,
  }) : super(givenName: givenName, familyName: familyName, email: email);

  factory RegisteredUser.fromJson(Map<String, Object?> json) {
    final authenticatedUser = AuthenticatedUser.fromJson(json);
    return RegisteredUser(
      id: authenticatedUser.id,
      givenName: authenticatedUser.givenName!,
      familyName: authenticatedUser.familyName,
      email: authenticatedUser.email!,
      picture: json["picture"] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        "id": id,
        "givenName": givenName,
        "familyName": familyName,
        "email": email,
        "picture": picture,
      };
}
