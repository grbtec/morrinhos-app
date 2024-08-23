import 'dart:convert';

import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/events/event_bus.dart';
import 'package:mobile/infrastructure/events/need_update_event.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:riverpod/riverpod.dart';

final _httpClientProvider = Provider((ref) => ProxyHttpClient(
      apiBaseUrl: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
      apiCaretVersion: MyConfig.instance.api.caretVersion,
    )); // Singleton

class DefaultHttpClientProvider {
  static Provider<http.Client> instance = _httpClientProvider;
}

extension HttpClientExtension on Ref {
  http.Client get httpClient {
    return read(DefaultHttpClientProvider.instance);
  }
}

class ProxyHttpClient implements http.Client {
  final http.Client httpClient = http.Client();
  final Uri apiBaseUrl;
  final String apiCaretVersion;

  ProxyHttpClient({
    required this.apiBaseUrl,
    required this.apiCaretVersion,
  });

  void responseHandler(http.BaseResponse response) {
    if (response.statusCode == 400) {
      if (response.request?.url.host == apiBaseUrl.host) {
        final apiSupportedVersion = response.headers["api-supported-versions"];
        if (apiSupportedVersion != null && apiSupportedVersion != "") {
          if (!_isCaretVersionSupported(apiCaretVersion, apiSupportedVersion)) {
            MyEventBus.instance.fire(NeedUpdateEvent());
          }
        }
      }
    }
  }

  @override
  void close() {
    return httpClient.close();
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.get(
      url,
      headers: headers,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.head(
      url,
      headers: headers,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.patch(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    futureResponse.then(responseHandler);
    return futureResponse;
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.read(url, headers: headers);
    return futureResponse;
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (url.host == apiBaseUrl.host) {
      headers ??= {};
      headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.readBytes(
      url,
      headers: headers,
    );
    return futureResponse;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    assert(apiCaretVersion[0] == "^", apiCaretVersion);
    if (request.url.host == apiBaseUrl.host) {
      request.headers["Accept-Version"] = apiCaretVersion;
    }
    final futureResponse = httpClient.send(request);
    futureResponse.then(responseHandler);
    return futureResponse;
  }
}

bool _isCaretVersionSupported(
    String apiCaretVersion, String apiSupportedVersion) {
  assert(apiCaretVersion[0] == "^");
  assert(!apiSupportedVersion.contains("^"));
  final apiCaretVersionParts = apiCaretVersion.replaceAll("^", "").split(".");
  final major = int.parse(apiCaretVersionParts[0]);
  final minor = int.parse(apiCaretVersionParts[1]);
  final apiSupportedVersionParts = apiSupportedVersion.split(".");
  final supportedMajor = int.parse(apiSupportedVersionParts[0]);
  final supportedMinor = int.parse(apiSupportedVersionParts[1]);
  if (supportedMajor != major) {
    return false;
  }
  if (supportedMinor < minor) {
    return false;
  }

  return true;
}

extension ResponseExtension on http.Response{
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}