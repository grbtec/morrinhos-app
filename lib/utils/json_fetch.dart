import 'dart:convert';

import 'package:async/async.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:http/http.dart';

mixin JsonFetch {
  Client get httpClient;

  Future<Result<Map<String, Object?>>> jsonFetch(
    Uri url, [
    String? body,
  ]) =>
      _jsonFetch(url, body);

  // The API usually wouldn't return any plain list, so this method is not used
  // Future<Result<List<Object?>>> jsonListFetch(Uri url) => _jsonFetch(url);

  Future<Result<T>> _jsonFetch<T>(Uri url, String? requestBody) async {
    final response = requestBody == null
        ? await httpClient.get(url)
        : await httpClient.post(url);

    if (response.statusCode != 200) {
      return Result.error(
          HttpError(message: response.body, status: response.statusCode));
    }

    final body = response.body;
    final json = jsonDecode(body) as T;
    return Result.value(json);
  }
}
