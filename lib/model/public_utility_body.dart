import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:mobile/model/geo_location_coordinates.dart';

class PublicUtilityBody {
  final String name;
  final String coverImageUrl;
  final GeoLocationCoordinates? location;
  final List<PublicUtilityBodyLink> links;

  PublicUtilityBody._raw({
    required this.name,
    required this.coverImageUrl,
    required this.location,
    required this.links,
  });

  factory PublicUtilityBody.fromJson(Map<String, Object?> json) {
    assert(json["name"] is String);
    assert(json["coverImageUrl"] is String);
    assert(json["location"] is Map<String, Object?>?);
    assert(json["links"] is List<Object?>);
    return PublicUtilityBody._raw(
      name: json["name"]! as String,
      coverImageUrl: json["coverImageUrl"]! as String,
      location: json["location"] == null
          ? null
          : GeoLocationCoordinates.fromJson(
              json["location"]! as Map<String, Object?>),
      links: (json["links"]! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map((json) => PublicUtilityBodyLink.fromJson(json))
          .toList(),
    );
  }
}

class PublicUtilityBodyLink {
  final PublicUtilityBodyLinkType linkType;
  final String title;
  final String actionText;
  final String actionUri;

  PublicUtilityBodyLink.raw({
    required this.linkType,
    required this.title,
    required this.actionText,
    required this.actionUri,
  });

  factory PublicUtilityBodyLink.fromJson(Map<String, Object?> json) {
    assert(json["linkType"] is String);
    assert(json["title"] is String);
    assert(json["actionText"] is String);
    assert(json["actionUri"] is String);
    return PublicUtilityBodyLink.raw(
      linkType: PublicUtilityBodyLinkType.from(json["linkType"]! as String),
      title: json["title"]! as String,
      actionText: json["actionText"]! as String,
      actionUri: json["actionUri"]! as String,
    );
  }
}

interface class PublicUtilityBodyLinkType extends Enumeration {
  static const PublicUtilityBodyLinkType other =
      PublicUtilityBodyLinkType(0, "Other");
  static const PublicUtilityBodyLinkType phone =
      PublicUtilityBodyLinkType(1, "Phone");
  static const PublicUtilityBodyLinkType email =
      PublicUtilityBodyLinkType(2, "Email");
  static const PublicUtilityBodyLinkType geo =
      PublicUtilityBodyLinkType(3, "Geo");
  static const PublicUtilityBodyLinkType url =
      PublicUtilityBodyLinkType(4, "Url");
  static const PublicUtilityBodyLinkType whatsApp =
      PublicUtilityBodyLinkType(5, "WhatsApp");

  const PublicUtilityBodyLinkType(super.id, super.name);

  factory PublicUtilityBodyLinkType.from(String value) {
    return switch (value) {
      "Other" => PublicUtilityBodyLinkType.other,
      "Phone" => PublicUtilityBodyLinkType.phone,
      "Email" => PublicUtilityBodyLinkType.email,
      "Geo" => PublicUtilityBodyLinkType.geo,
      "Url" => PublicUtilityBodyLinkType.url,
      "WhatsApp" => PublicUtilityBodyLinkType.whatsApp,
      _ => throw ArgumentError("Unknown value: $value"),
    };
  }
}
