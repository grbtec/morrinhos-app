import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/tenant_config.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

final deepLinkSettingsProvider = FutureProvider((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final persisted = prefs.getString("deepLinkSettings")?.transform((json) {
    try {
      return DeepLinkSettings.fromJson(
          jsonDecode(json) as Map<String, Object?>);
    } catch (exception) {
      Future.microtask(() => throw exception);
      return null;
    }
  });
  if (persisted != null) {
    unawaited(
      Future(() async {
        final updated = await _getDeepLinkSettings(ref);
        await prefs.setString("deepLinkSettings", jsonEncode(updated));
        if (persisted != updated) {
          ref.state = AsyncValue.data(updated);
          if (kDebugMode) {
            print("[DEBUG] persisted: '${persisted.toJson()}'. updated: '${updated.toJson()}'");
            print("[DEBUG] Deep Link settings revalidated");
          }
        }
      }),
    );
    return persisted;
  }
  final updated = await _getDeepLinkSettings(ref);
  unawaited(prefs.setString("deepLinkSettings", jsonEncode(updated)));
  return updated;
});

class DeepLinkSettings {
  final String baseUrl;
  final Map<String, String> routesMap;

  DeepLinkSettings._raw({
    required this.baseUrl,
    required this.routesMap,
  });

  factory DeepLinkSettings.fromJson(Map<String, Object?> json) {
    assert(json["baseUrl"] is String);
    assert(json["routesMap"] is Map<Object?, Object?>?);
    return DeepLinkSettings._raw(
      baseUrl: json["baseUrl"]! as String,
      routesMap: (json["routesMap"] as Map<Object?, Object?>? ?? {}).cast(),
    );
  }

  Map<String,Object?> toJson() =>{
    "baseUrl": baseUrl,
    "routesMap": routesMap,
  };


  @override
  bool operator ==(Object other) =>
      other is DeepLinkSettings &&
          other.baseUrl == baseUrl &&
          other.routesMap.valueHashCode == routesMap.valueHashCode;

  @override
  int get hashCode =>
      Object.hash(
        baseUrl,
        routesMap.valueHashCode,
      );
}

Future<DeepLinkSettings> _getDeepLinkSettings(Ref ref) async {
  final apiBaseUrl = MyConfig.instance.api.getBaseUri(ref.tenantSlug);
  final tenantSettingsUrl =
      apiBaseUrl.replace(path: "/tenant/current/deep-link-settings");
  final response = await ref.httpClient.get(tenantSettingsUrl);
  if (!response.isSuccess) {
    throw Result.error(
      HttpError(message: response.body, status: response.statusCode),
    );
  }
  final json = jsonDecode(response.body) as Map<String, Object?>;
  return DeepLinkSettings.fromJson(json);
}

extension _MapExtensions<T, U> on Map<T, U>{
  int get valueHashCode {
    return Object.hashAllUnordered(
      entries.map((e) => Object.hash(e.key, e.value)),
    );
  }
}