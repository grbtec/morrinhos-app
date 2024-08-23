import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/infrastructure/json_cache_manager.dart';
import 'package:mobile/model/layout.dart';
import 'package:mobile/model/layout_special_widget_model.dart';
import 'package:mobile/model/layout_view_widget.dart';
import 'package:mobile/model/layout_widget_variant.dart';
import 'package:mobile/model/mobile_preferences.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/repositories/since_repository.dart';
import 'package:mobile/utils/exception_handler.dart';
import 'package:mobile/utils/http_error_handler.dart';
import 'package:mobile/utils/json_fetch.dart';

final layoutRepositoryProvider = Provider.autoDispose(
  (ref) => LayoutRepository(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    sinceRepository: ref.watch(sinceRepositoryProvider),
    cacheManager: ref.read(jsonCacheManagerProvider),
  ),
);

class LayoutRepository with JsonFetch {
  final SinceRepository sinceRepository;
  @override
  final Client httpClient;
  final Uri apiBaseUri;
  final JsonCacheManager? cacheManager;

  LayoutRepository({
    required this.httpClient,
    required this.apiBaseUri,
    required this.sinceRepository,
    required this.cacheManager,
  });

  setLayoutNotification(String id) {
    unawaited(sinceRepository.setSince(id));
  }

  Future<Result<int>> getLayoutNotification(String id) async {
    final String since = await sinceRepository.getSince(id);

    final url = apiBaseUri.replace(
      path: "/layout-widgets/$id/notification-count",
      queryParameters: {"since": since},
    );

    final response = await httpClient.get(url);
    final body = response.body;

    if (response.statusCode != 200) {
      return httpErrorHandler(response.statusCode);
    }

    final jsonResponse = jsonDecode(body) as Map<String, Object?>;

    if (jsonResponse["value"] != null) {
      final int value = jsonResponse["value"] as int;

      return Result.value(value);
    } else {
      return Result.value(0);
    }
  }

  Future<Result<Variant<LayoutWidgetVariant>>> getLayoutWidget(
    String id, {
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final url = apiBaseUri.replace(path: "/layout-widgets/$id");

      final jsonResult = await cacheManager?.handle(useCache, url, jsonFetch) ??
          await jsonFetch(url);
      if (jsonResult is ErrorResult) {
        return Result.error(jsonResult.error);
      }
      final json = jsonResult.asValue!.value;

      final Variant<LayoutWidgetVariant> obj;

      assert(json["variant"] is String);

      switch (json["variant"]! as String) {
        case "View":
          obj = LayoutViewWidget.fromJson(json);
        case "Special":
          obj = LayoutSpecialWidget.fromJson(json);
        default:
          return Result.error(
            "Variante de widget não esperada. Atualize o aplicativo.",
          );
      }
      return Result.value(obj);
    });
  }

  // Future<Result<Layout>> getLayout(
  //   String id, {
  //   bool useCache = false,
  // }) async {
  //   return ExceptionHandler.convertToNoConnectionResult(() async {
  //     final url = apiBaseUri.replace(path: "/layouts/$id");
  //
  //     final jsonResult = await cacheManager?.handle(useCache, url, jsonFetch) ??
  //         await jsonFetch(url);
  //     if (jsonResult is ErrorResult) {
  //       return Result.error(jsonResult.error);
  //     }
  //     final json = jsonResult.asValue!.value;
  //
  //     final layoutModel = Layout.fromJson(json);
  //
  //     return Result.value(layoutModel);
  //   });
  // }

  Future<Result<Layout?>> getDefaultLayout({
    bool useCache = false,
  }) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final mobilePreferencesUrl =
          apiBaseUri.replace(path: "/mobile-preferences");

      final mobilePreferencesJsonResult = await cacheManager?.handle(
              useCache, mobilePreferencesUrl, jsonFetch) ??
          await jsonFetch(mobilePreferencesUrl);
      if (mobilePreferencesJsonResult is ErrorResult) {
        return Result.error(mobilePreferencesJsonResult.error);
      }
      final mobilePreferencesJson = mobilePreferencesJsonResult.asValue!.value;

      final mobilePreferences =
          MobilePreferences.fromJson(mobilePreferencesJson);

      final defaultLayoutId = mobilePreferences.defaultLayout?.id;
      if (defaultLayoutId == null) return Result.value(null);
      final layoutUrl = apiBaseUri.replace(path: "/layouts/$defaultLayoutId");

      final layoutJsonResult =
          await cacheManager?.handle(useCache, layoutUrl, jsonFetch) ??
              await jsonFetch(layoutUrl);
      if (layoutJsonResult is ErrorResult) {
        return Result.error(layoutJsonResult.error);
      }
      final layoutJson = layoutJsonResult.asValue!.value;
      final layoutModel = Layout.fromJson(layoutJson);

      return Result.value(layoutModel);
    });
  }
}
