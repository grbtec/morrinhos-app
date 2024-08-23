import 'package:gbt_essentials/gbt_dart_essentials.dart';

class JobVacancy {
  final IdHolder employer;
  final String title;
  final String comments;
  final String coverImageUrl;
  final Map<String, String?> additionalInfo;
  final Map<String, String?> metadata;

  JobVacancy._raw({
    required this.employer,
    required this.title,
    required this.comments,
    required this.coverImageUrl,
    required this.additionalInfo,
    required this.metadata,
  });

  factory JobVacancy.fromJson(Map<String, Object?> json) {
    assert(json["employer"] is Map<String, Object?>);
    assert(json["title"] is String);
    assert(json["comments"] is String);
    assert(json["coverImageUrl"] is String);
    assert(json["additionalInfo"] is Map<String, Object?>);
    assert(json["metadata"] is Map<String, Object?>);
    return JobVacancy._raw(
      employer: IdHolder.fromJson(json["employer"]! as Map<String, Object?>),
      title: json["title"]! as String,
      comments: json["comments"]! as String,
      coverImageUrl: json["coverImageUrl"]! as String,
      additionalInfo:
          (json["additionalInfo"] as Map<Object?, Object?>? ?? {}).cast(),
      metadata:
      (json["additionalInfo"] as Map<Object?, Object?>? ?? {}).cast(),
    );
  }

  Map<String, Object?> toJson()=>{
    "employer": employer.toJson(),
    "title": title,
    "comments": comments,
    "coverImageUrl": coverImageUrl,
    "additionalInfo": additionalInfo,
    "metadata": metadata,
  };
}
