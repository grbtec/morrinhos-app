import 'package:gbt_identity/registered_user.dart';

class AppUserDto extends RegisteredUser {
  AppUserDto._raw({
    required super.id,
    required super.givenName,
    required super.familyName,
    required super.email,
    required super.picture,
  });

  factory AppUserDto.fromJson(Map<String, Object?> json) {
    assert(json["id"] is String);
    assert(json["givenName"] is String);
    assert(json["familyName"] is String?);
    assert(json["email"] is String);
    assert(json["picture"] is String?);
    return AppUserDto._raw(
      id: json["id"]! as String,
      givenName: json["givenName"]! as String,
      familyName: json["familyName"] as String?,
      email: json["email"]! as String,
      picture: json["picture"] as String?,
    );
  }
}
