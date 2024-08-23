import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/infrastructure/json_cache_manager.dart';
import 'package:mobile/model/employer.dart';
import 'package:mobile/model/search_item.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';
import 'package:mobile/utils/json_fetch.dart';

final searchRepositoryProvider = Provider.autoDispose((ref) {
  return SearchRepository(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    cacheManager: ref.read(jsonCacheManagerProvider),
  );
});

class SearchRepository with JsonFetch {
  static const basePath = "/search";
  @override
  final Client httpClient;
  final Uri apiBaseUri;
  final JsonCacheManager? cacheManager;

  SearchRepository({
    required this.httpClient,
    required this.apiBaseUri,
    required this.cacheManager,
  });

  Future<Result<PagedList<SearchItem>>> searchPaged({
    required List<SearchItemVariant> variants,
    required String search,
    int pageNumber = 0,
    int? pageSize,
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(
        path: "search/search",
        queryParameters: {
          "pageNumber": pageNumber.toString(),
          if (pageSize != null) "pageSize": pageSize.toString(),
          "filter": "variant__${variants.map((e) => e.name).join(",")}",
          "q": search,
        },
      );
      fetch(Uri url) => jsonFetch(url, "");

      final jsonResult =
          await cacheManager?.handle(useCache, url, fetch) ?? await fetch(url);
      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final pagedList = PagedList.fromJson(json, SearchItem.fromJson);
      return Result.value(pagedList);
    });
  }

  Future<Result<Employer>> getEmployer(
    String id, {
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "$basePath/$id");

      final jsonResult = await cacheManager?.handle(useCache, url, jsonFetch) ??
          await jsonFetch(url);
      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final employer = Employer.fromJson(json);
      return Result.value(employer);
    });
  }
}
