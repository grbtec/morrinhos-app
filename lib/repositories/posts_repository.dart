import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/infrastructure/json_cache_manager.dart';
import 'package:mobile/model/engagement_metrics.dart';
import 'package:mobile/model/post.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';
import 'package:mobile/utils/json_fetch.dart';

final postsRepositoryProvider = Provider.autoDispose(
  (ref) => PostsRepository(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    cacheManager: ref.read(jsonCacheManagerProvider),
  ),
);

class PostsRepository with JsonFetch {
  static const basePath = "/posts";
  @override
  final Client httpClient;
  final Uri apiBaseUri;
  final JsonCacheManager? cacheManager;

  PostsRepository({
    required this.httpClient,
    required this.apiBaseUri,
    required this.cacheManager,
  });

  Future<Result<PagedList<IdHolder>>> getJobPostsPaged({
    int pageNumber = 0,
    int? pageSize,
    bool? pinned,
    String? search,
    String? employerId,
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = search == null
          ? apiBaseUri.replace(
              path: basePath,
              queryParameters: {
                "pageNumber": pageNumber.toString(),
                if (pageSize != null) "pageSize": pageSize.toString(),
                "filter": [
                  "relation.referenceType__JobVacancy",
                  if (employerId != null) "publisher.id__$employerId",
                  "expirationDateTime__",
                  if (pinned != null)
                    if (pinned)
                      "metadata.pinned__true"
                    else
                      "!metadata.pinned__true",
                ],
              },
            )
          : apiBaseUri.replace(
              path: "search/search",
              queryParameters: {
                "pageNumber": pageNumber.toString(),
                if (pageSize != null) "pageSize": pageSize.toString(),
                "filter": [
                  "variant__Post",
                  "post.relation.referenceType__JobVacancy",
                  if (employerId != null) "post.publisher.id__$employerId",
                ],
                "q": search,
              },
            );
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

  Future<Result<Post>> getOne(
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

      final obj = Post.fromJson(json);
      return Result.value(obj);
    });
  }

  Future<Result<EngagementMetrics>> getPostEgagementMetrics(
    String id, {
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "$basePath/$id/engagement-metrics");

      final jsonResult = await cacheManager?.handle(useCache, url, jsonFetch) ??
          await jsonFetch(url);
      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final obj = EngagementMetrics.fromJson(json);
      return Result.value(obj);
    });
  }

  Future<Result<void>> incrementPostViewCount(String id) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "$basePath/$id/increment-view-count");
      final response = await httpClient.post(url);

      if (!response.isSuccess && response.statusCode != 400) {
        return Result.error(
            HttpError(message: response.body, status: response.statusCode));
      }
      if (response.statusCode == 400) {
        final body = response.body;
        final json = jsonDecode(body) as Map<String, Object?>;
        return Result.error(json["error"] ?? ValidationErrors.fromJson(json));
      }
      return Result.value(null);
    });
  }
}
