import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/tenant_config.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tenantSlugProvider = FutureProvider((ref) async {
  if (kDebugMode) {
    print("[DEBUG] Loading tenant slug...");
  }
  final tenantSlug = await _TenantSlugService(
    prefs: SharedPreferences.getInstance(),
    httpClient: ProxyHttpClient(
      apiBaseUrl: MyConfig.instance.api.getBaseUri("void"),
      apiCaretVersion: MyConfig.instance.api.caretVersion,
    ),
    apiBaseUri: MyConfig.instance.api.getBaseUri("void"),
    tenantUid: TenantConfig.instance.uid,
  ).getTenantSlug(
      revalidate: ref.state.hasValue
          ? null
          : (persisted, updated) {
              if (persisted != updated) {
                ref.state = AsyncValue.data(updated);
                if (kDebugMode) {
                  print("[DEBUG] persisted: '$persisted'. updated: '$updated'");
                  print("[DEBUG] Tenant slug revalidated");
                }
              }
            });
  return tenantSlug;
});

class _TenantSlugService {
  final Future<SharedPreferences> prefs;
  final Client httpClient;
  final Uri apiBaseUri;
  final String tenantUid;

  _TenantSlugService({
    required this.prefs,
    required this.httpClient,
    required this.apiBaseUri,
    required this.tenantUid,
  });

  Future<String> getTenantSlug(
      {required void Function(String persisted, String updated)?
          revalidate}) async {
    final sharedPreferences = await prefs;
    final persistedTenantSlug = sharedPreferences.getString("tenantSlug");

    if (persistedTenantSlug != null) {
      if (revalidate != null) {
        unawaited(Future(() async {
          final updatedTenantSlug =
              await getUpdatedTenantSlug().unwrapOrThrowResult();
           unawaited(sharedPreferences.setString("tenantSlug", updatedTenantSlug));
          revalidate(persistedTenantSlug, updatedTenantSlug);
        }));
      }
      return persistedTenantSlug;
    }

    final updatedTenantSlug =
        await getUpdatedTenantSlug().unwrapOrThrowResult();
    unawaited(sharedPreferences.setString("tenantSlug", updatedTenantSlug));
    return updatedTenantSlug;
  }

  Future<Result<String>> getUpdatedTenantSlug() async {
    final response = await httpClient.get(
        apiBaseUri.replace(path: "/tenant/${TenantConfig.instance.uid}/slug"));

    if (!response.isSuccess) {
      return Result.error(
          HttpError(message: response.body, status: response.statusCode));
    }
    final json = jsonDecode(response.body) as Map<String, Object?>;
    return Result.value(json["slug"]! as String);
  }
}

extension TenantSlugProviderExtension on Ref {
  String get tenantSlug {
    return watch(tenantSlugProvider).requireValue;
  }
}

extension TenantSlugWidgetExtension on WidgetRef {
  String get tenantSlug {
    return watch(tenantSlugProvider).requireValue;
  }
}
