const _json = {"uid":"dGVuYW50cy82NS1D"};

class TenantConfig {
  static final TenantConfig instance = TenantConfig._fromJson(_json);
  final String uid;

  const TenantConfig._raw({
    required this.uid,
  });

  factory TenantConfig._fromJson(Map<String, Object?> json) {
    assert(json["uid"] is String);

    return TenantConfig._raw(
      uid: json["uid"]! as String,
    );
  }
}
