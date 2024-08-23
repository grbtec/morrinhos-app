class User {
  final String id;

  const User({
    required this.id,
  });

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: (json["userId"] ?? json["sub"] ?? json["id"])! as String,
    );
  }
}
