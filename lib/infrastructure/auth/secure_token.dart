import 'package:gbt_identity/registered_user.dart';
import 'package:gbt_identity/user.dart';

class SecureToken<T extends RegisteredUser> {
  final T user;
  final String refreshToken;

  SecureToken({
    required this.user,
    required this.refreshToken,
  });

  factory SecureToken.fromJson(Map<String, Object?> json, T Function(Map<String, Object?> json) userFromJson) {
    return SecureToken(
      user: userFromJson(json["user"]! as Map<String, Object?>),
      refreshToken: json["refreshToken"]! as String,
    );
  }

  Map<String, Object?> toJson() => {
    "user": user.toJson(),
    "refreshToken": refreshToken,
  };
}
