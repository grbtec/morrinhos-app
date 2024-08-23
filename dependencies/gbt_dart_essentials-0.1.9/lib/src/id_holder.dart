// ignore:public_member_api_docs
class IdHolder {
  // ignore:public_member_api_docs
  final String id;

  // ignore:public_member_api_docs
  const IdHolder({
    required this.id,
  });

  // ignore:public_member_api_docs
  factory IdHolder.fromJson(Map<String, Object?> json) {
    assert(json["id"] is String);
    return IdHolder(id: json["id"]! as String);
  }

  Map<String, Object?> toJson()=>{
    "id": id,
  };
}
