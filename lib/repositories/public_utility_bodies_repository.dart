import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/infrastructure/json_cache_manager.dart';
import 'package:mobile/model/public_utility_body.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';
import 'package:mobile/utils/json_fetch.dart';

final publicUtilityBodiesRepositoryProvider = Provider.autoDispose(
  (ref) => PublicUtilityBodiesRepository(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    cacheManager: ref.read(jsonCacheManagerProvider),
  ),
);

class PublicUtilityBodiesRepository with JsonFetch {
  static const basePath = "/public-utility-bodies";
  @override
  final Client httpClient;
  final Uri apiBaseUri;
  final JsonCacheManager? cacheManager;

  PublicUtilityBodiesRepository({
    required this.httpClient,
    required this.apiBaseUri,
    required this.cacheManager,
  });

  Future<Result<PagedList<IdHolder>>> getPaged({
    int pageNumber = 0,
    int? pageSize,
    String? search,
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = search == null
          ? apiBaseUri.replace(
              path: basePath,
              queryParameters: {
                "pageNumber": pageNumber.toString(),
                if (pageSize != null) "pageSize": pageSize.toString(),
              },
            )
          : apiBaseUri.replace(
              path: "search/search",
              queryParameters: {
                "pageNumber": pageNumber.toString(),
                if (pageSize != null) "pageSize": pageSize.toString(),
                "filter": "variant__PublicUtilityBody",
                "q": search,
              },
            );

      // ignore: always_declare_return_types
      fetch(Uri url) => jsonFetch(url, search == null ? null : "");

      final jsonResult =
          await cacheManager?.handle(useCache, url, fetch) ?? await fetch(url);

      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final pagedList = PagedList.fromJson(json, IdHolder.fromJson);
      return Result.value(pagedList);
    });
  }

  Future<Result<PublicUtilityBody>> getOne(
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

      final obj = PublicUtilityBody.fromJson(json);
      return Result.value(obj);
    });
  }
}
