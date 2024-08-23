import 'package:gbt_dart_essentials/src/constructor.dart';

// ignore:public_member_api_docs
class PagedList<T> {
  // ignore:public_member_api_docs
  final int currentPage;

  // ignore:public_member_api_docs
  final int pageSize;

  // ignore:public_member_api_docs
  final List<T> results;

  // ignore:public_member_api_docs
  const PagedList.raw({
    required this.currentPage,
    required this.pageSize,
    required this.results,
  });

  // ignore:public_member_api_docs
  factory PagedList.fromJson(
    Map<String, Object?> jsonObject,
    FromJsonObjectConstructor<T> constructor,
  ) {
    return PagedList.raw(
      currentPage: jsonObject["currentPage"]! as int,
      pageSize: jsonObject["pageSize"]! as int,
      results: (jsonObject["results"]! as List<dynamic>)
          .cast<Map<String, Object?>>()
          .map((jsonObject) {
        return constructor(jsonObject);
      }).toList(),
    );
  }
}
