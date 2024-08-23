import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_identity/registered_user.dart';
import 'package:gbt_identity/user_credential.dart';
import 'package:http/http.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/infrastructure/json_cache_manager.dart';
import 'package:mobile/model/employer.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';
import 'package:mobile/utils/json_fetch.dart';

final employersRepositoryProvider = Provider.autoDispose((ref) {
  return EmployersRepository(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    userCrendential: ref.watch(userCredentialProvider).valueOrNull,
    cacheManager: ref.read(jsonCacheManagerProvider),
  );
});

class EmployersRepository with JsonFetch {
  static const basePath = "/employers";
  @override
  final Client httpClient;
  final Uri apiBaseUri;
  final UserCredential<RegisteredUser>? userCrendential;
  final JsonCacheManager? cacheManager;

  EmployersRepository({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userCrendential,
    required this.cacheManager,
  });

  Future<Result<bool>> checkCreationPermission() async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: basePath);
      final userTokens = await userCrendential?.getValidUserTokens();
      final response = await httpClient.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (userTokens != null)
            "Authorization":
            "${userTokens.tokenType} ${userTokens.accessToken}",
        },
        body: jsonEncode({}),
      );
      if (!response.isSuccess && response.statusCode != 400) {
        return Result.error(
            HttpError(message: response.body, status: response.statusCode));
      }

      if (response.statusCode != 400) {
        return Result.value(false);
      }

      return Result.value(true);
    });
  }

  Future<Result<void>> create(Map<String, Object?> requestBody) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: basePath);
      final userTokens = await userCrendential?.getValidUserTokens();
      final response = await httpClient.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (userTokens != null)
            "Authorization":
            "${userTokens.tokenType} ${userTokens.accessToken}",
        },
        body: jsonEncode(requestBody),
      );
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

  Future<Result<void>> update(
      String id, Map<String, Object?> requestBody) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "$basePath/$id");
      final userTokens = await userCrendential?.getValidUserTokens();
      final response = await httpClient.put(
        url,
        headers: {
          "Content-Type": "application/json",
          if (userTokens != null)
            "Authorization":
            "${userTokens.tokenType} ${userTokens.accessToken}",
        },
        body: jsonEncode(requestBody),
      );
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

  Future<Result<void>> delete(String id) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "$basePath/$id");
      final userTokens = await userCrendential?.getValidUserTokens();
      final response = await httpClient.delete(
        url,
        headers: {
          if (userTokens != null)
            "Authorization":
            "${userTokens.tokenType} ${userTokens.accessToken}",
        },
      );
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

  Future<Result<PagedList<IdHolder>>> getEmployersPaged({
    int pageNumber = 0,
    int? pageSize,
    bool? pinned,
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
                "filter": [
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
                "filter": "variant__Employer",
                "showHidden": "true",
                "q": search,
              },
            );
      fetch(Uri url) => jsonFetch(url, search == null ? null : "");

      final jsonResult = await cacheManager?.handle(useCache, url, fetch) ??
          await fetch(url);
      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final pagedList = PagedList.fromJson(json, IdHolder.fromJson);
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
