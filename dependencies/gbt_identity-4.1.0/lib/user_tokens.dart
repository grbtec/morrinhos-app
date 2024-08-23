class UserTokens {
  final String idToken;
  final String accessToken;
  final DateTime expiresAt;
  final String? tokenType;

  const UserTokens({
    required this.idToken,
    required this.accessToken,
    required this.expiresAt,
    required this.tokenType,
  });

  factory UserTokens.fromJson(Map<String, Object?> json) {
    var expiresAt = json["expires_at"] as num?;
    if (expiresAt == null) {
      // if expiresIn is been used, it will cause token renew every time
      // TODO: Convert expiresIn to expiresAt
      // final expiresIn = json["expires_in"];
    }
    return UserTokens(
      idToken: json["id_token"]! as String,
      accessToken: json["access_token"]! as String,
      expiresAt: expiresAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch((expiresAt * 1000).toInt()),
      tokenType: json["token_type"]! as String,
    );
  }
}
