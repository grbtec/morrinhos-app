class Employer {
  final DateTime creationDateTime;
  final String name;
  final String logoUrl;

  Employer._raw({
    required this.creationDateTime,
    required this.name,
    required this.logoUrl,
  });

  factory Employer.fromJson(Map<String, Object?> json) {
    assert(json["creationDateTime"] is String);
    assert(json["name"] is String);
    assert(json["logoUrl"] is String);

    return Employer._raw(
      creationDateTime: DateTime.parse(json["creationDateTime"]! as String),
      name: json["name"]! as String,
      logoUrl: json["logoUrl"]! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "creationDateTime": creationDateTime.toIso8601String(),
      "name": name,
      "logoUrl": logoUrl,
    };
  }
}
