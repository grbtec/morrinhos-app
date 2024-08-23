import 'package:gbt_essentials/gbt_dart_essentials.dart';

class MobilePreferences {
  final String id;
  final IdHolder? defaultLayout;

  MobilePreferences._raw({
    required this.id,
    required this.defaultLayout,
  });

  factory MobilePreferences.fromJson(Map<String, Object?> json) {
    assert(json["id"] is String);
    assert(json["defaultLayout"] is Map<String, Object?>?);
    return MobilePreferences._raw(
      id: json["id"]! as String,
      defaultLayout: json["defaultLayout"] == null
          ? null
          : IdHolder.fromJson(json["defaultLayout"]! as Map<String, Object?>),
    );
  }
}
