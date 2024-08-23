import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jsonCacheManagerProvider =
    Provider.autoDispose((ref) => JsonCacheManager());

class JsonCacheManager {
  static const key = 'JsonCacheManager';
  final CacheManager _cacheManager = CacheManager(Config(key));

  Future<void> update(String key, Map<String, Object?> json) async {
    try {
      final jsonStr = jsonEncode(json);
      await _cacheManager.putFile(key, utf8.encode(jsonStr));
    } catch (error, stackTrace) {
      Future.microtask(() => Error.throwWithStackTrace(error, stackTrace));
    }
  }

  Future<Map<String, Object?>?> get(String key) async {
    try {
      final file = await _cacheManager.getFileFromCache(key);
      if (file != null) {
        final fileContent = await file.file.readAsString();
        if(fileContent.isEmpty){
          if(kDebugMode) {
            print("[DEBUG] Empty cache for $key");
          }
          return null;
        }
        final json = jsonDecode(fileContent);
        if (kDebugMode) {
          print("[CACHED] $key");
        }
        return json as Map<String, Object?>;
      }
    } catch (error, stackTrace) {
      unawaited(Future.microtask(() => Error.throwWithStackTrace(error, stackTrace)));
    }
    return null;
  }

  Future<Result<Map<String,Object?>>> handle(bool useCache, Uri url, Future<Result<Map<String,Object?>>> Function(Uri url) fetch ) async {
    final cachedJson = !useCache ? null : await get(url.toString());
    if (cachedJson != null) {
      return Result.value(cachedJson);
    }
    final response = await fetch(url);
    if (response is! ValueResult<Map<String, Object?>>) {
      return response;
    }
    final json = response.value;
    await update(url.toString(), json);
    return Result.value(json);
  }
}
