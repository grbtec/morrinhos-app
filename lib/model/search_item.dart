import 'package:gbt_essentials/gbt_dart_essentials.dart';

class SearchItem implements Variant<SearchItemVariant> {
  @override
  SearchItemVariant variant;
  String id;
  String title;
  String? subtitle;
  String? imageUrl;

  SearchItem._raw({
    required this.variant,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory SearchItem.fromJson(Map<String, Object?> json) {
    assert(json["variant"] is String);
    assert(json["id"] is String);
    assert(json["title"] is String);
    assert(json["subtitle"] is String?);
    assert(json["imageUrl"] is String?);
    final variant = switch (json["variant"] as String) {
      "Post" => SearchItemVariant.post,
      "Employer" => SearchItemVariant.employer,
      _ => const SearchItemVariant(-1, "Unknown"),
    };
    return SearchItem._raw(
      variant: variant,
      id: json["id"]! as String,
      title: json["title"]! as String,
      subtitle: json["subtitle"] as String?,
      imageUrl: json["imageUrl"] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "title": title,
      "subtitle": subtitle,
      "imageUrl": imageUrl,
    };
  }
}

interface class SearchItemVariant extends Enumeration {
  static const SearchItemVariant post = SearchItemVariant(0, "Post");
  static const SearchItemVariant employer = SearchItemVariant(1, "Employer");

  const SearchItemVariant(super.id, super.name);
}
