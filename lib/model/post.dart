import 'package:gbt_essentials/gbt_dart_essentials.dart';

class Post {
  final DateTime creationDateTime;
  final DateTime? expirationDateTime;
  final PostPublisher? publisher;
  final PostRelation? relation;
  final String title;
  final String subtitle;
  final String coverImageUrl;
  final Map<String, String> metadata;

  Post._raw({
    required this.creationDateTime,
    required this.expirationDateTime,
    required this.publisher,
    required this.relation,
    required this.title,
    required this.subtitle,
    required this.coverImageUrl,
    required this.metadata,
  });

  factory Post.fromJson(Map<String, Object?> json) {
    assert(json["creationDateTime"] is String);
    assert(json["expirationDateTime"] is String?);
    assert(json["publisher"] is Map<String, Object?>?);
    assert(json["relation"] is Map<String, Object?>?);
    assert(json["title"] is String);
    assert(json["subtitle"] is String);
    assert(json["coverImageUrl"] is String);
    assert(json["metadata"] is Map<Object?, Object?>);
    return Post._raw(
      creationDateTime: DateTime.parse(json["creationDateTime"] as String),
      expirationDateTime: json["expirationDateTime"] == null
          ? null
          : DateTime.parse(json["expirationDateTime"] as String),
      publisher: json["publisher"] == null
          ? null
          : PostPublisher.fromJson(json["publisher"] as Map<String, Object?>),
      relation: json["relation"] == null
          ? null
          : PostRelation.fromJson(json["relation"] as Map<String, Object?>),
      title: json["title"] as String,
      subtitle: json["subtitle"] as String,
      coverImageUrl: json["coverImageUrl"] as String,
      metadata: (json["metadata"] as Map<Object?, Object?>? ?? {}).cast(),
    );
  }
}

class PostPublisher {
  final PublisherType publisherType;
  final String id;
  final String name;
  final String logoUrl;

  PostPublisher._raw({
    required this.publisherType,
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory PostPublisher.fromJson(Map<String, Object?> json) {
    assert(json["publisherType"] is String);
    assert(json["id"] is String);
    assert(json["name"] is String);
    assert(json["logoUrl"] is String);
    return PostPublisher._raw(
      publisherType: PublisherType.from(json["publisherType"]! as String),
      id: json["id"] as String,
      name: json["name"] as String,
      logoUrl: json["logoUrl"] as String,
    );
  }
}

interface class PublisherType extends Enumeration {
  static const PublisherType employer = PublisherType(0, "Employer");

  const PublisherType(super.id, super.name);

  factory PublisherType.from(String value) {
    return switch (value) {
      "Employer" => PublisherType.employer,
      _ => throw ArgumentError("Unknown value: $value"),
    };
  }
}

class PostRelation {
  final PostRelationReferenceType referenceType;
  final String id;
  final DateTime revision;

  PostRelation._raw({
    required this.referenceType,
    required this.id,
    required this.revision,
  });

  factory PostRelation.fromJson(Map<String, Object?> json) {
    assert(json["referenceType"] is String);
    assert(json["id"] is String);
    return PostRelation._raw(
      referenceType: switch (json["referenceType"] as String?) {
        "JobVacancy" => PostRelationReferenceType.jobVacancy,
        _ =>
          throw "Invalid PostRelationReferenceType: ${json["referenceType"]}",
      },
      id: json["id"]! as String,
      revision: DateTime.parse(json["revision"]! as String),
    );
  }
}

interface class PostRelationReferenceType extends Enumeration {
  static const PostRelationReferenceType jobVacancy =
      PostRelationReferenceType(0, "JobVacancy");

  const PostRelationReferenceType(super.id, super.name);
}
