import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_identity/registered_user.dart';
import 'package:gbt_identity/user_tokens.dart';
import 'package:http/http.dart';
import 'package:mobile/infrastructure/auth/app_user_dto.dart';
import 'package:mobile/config/my_config.dart';
import 'package:mobile/infrastructure/http_client.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/utils/exception_handler.dart';

final authServiceProvider = Provider.autoDispose<AuthService>((ref) {
  return AuthService(
    httpClient: ref.httpClient,
    apiBaseUri: MyConfig.instance.api.getBaseUri(ref.tenantSlug),
    clientId: MyConfig.instance.auth.clientId,
  );
});

class AuthService {
  final Client httpClient;
  final Uri apiBaseUri;
  final String clientId;

  AuthService({
    required this.httpClient,
    required this.apiBaseUri,
    required this.clientId,
  });

  Future<Result<AspNetTokenResponse>> signIn(
      String username, String password) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final response = await httpClient.post(
        apiBaseUri.replace(path: "/auth/token"),
        body: jsonEncode({
          "client_id": clientId,
          "grant_type": "password",
          "username": username,
          "password": password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 400) {
        final validationErrorsJson =
            jsonDecode(response.body) as Map<String, Object?>;

        return Result.error(validationErrorsJson["error"] ??
            validationErrorsJson["error"].toString());
      }

      if (response.statusCode != 200) {
        return Result.error(
            HttpError(message: response.body, status: response.statusCode));
      }

      final json = jsonDecode(response.body) as Map<String, Object?>;

      return Result.value(AspNetTokenResponse.fromJson(json));
    });
  }

  Future<Result<AspNetTokenResponse>> renew(String refreshToken) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final response = await httpClient.post(
        apiBaseUri.replace(path: '/auth/token'),
        body: jsonEncode({
          "client_id": clientId,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        return Result.error(
            HttpError(message: response.body, status: response.statusCode));
      }

      final json = jsonDecode(response.body) as Map<String, Object?>;

      return Result.value(AspNetTokenResponse.fromJson(json));
    });
  }

  Future<Result<void>> revoke(String refreshToken) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final response = await httpClient.post(
        apiBaseUri.replace(path: '/auth/revoke'),
        body: jsonEncode({
          'token': refreshToken,
          'token_type_hint': 'refresh_token',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (!response.isSuccess) {
        return Result.error(
            HttpError(message: response.body, status: response.statusCode));
      }

      return Result.value(null);
    });
  }

  Future<Result<RegisteredUser>> getMe(UserTokens userTokens) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final response = await httpClient.get(
        apiBaseUri.replace(path: '/me'),
        headers: {
          "Authorization": "${userTokens.tokenType} ${userTokens.accessToken}",
        },
      );

      if (response.statusCode != 200) {
        return Result.error(
          HttpError(message: response.body, status: response.statusCode),
        );
      }

      final json = jsonDecode(response.body) as Map<String, Object?>;

      return Result.value(AppUserDto.fromJson(json));
    });
  }

  Future<Result<List<Object?>>> claims(UserTokens userTokens) async {
    return ExceptionHandler.convertToNoConnectionResult(() async {
      final response = await httpClient.get(
        apiBaseUri.replace(
          path: '/auth/claims',
        ),
        headers: {
          "Authorization": "${userTokens.tokenType} ${userTokens.accessToken}",
        },
      );

      if (response.statusCode != 200) {
        return Result.error(
          HttpError(message: response.body, status: response.statusCode),
        );
      }

      final json = jsonDecode(response.body) as List<Object?>;

      return Result.value(json);
    });
  }
}

class AspNetTokenResponse {
  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final String refreshToken;

  AspNetTokenResponse({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
  });

  //
  factory AspNetTokenResponse.fromJson(Map<String, Object?> json) {
    assert(json["token_type"] is String);
    assert(json["access_token"] is String);
    assert(json["expires_in"] is int);
    assert(json["refresh_token"] is String);
    return AspNetTokenResponse(
      tokenType: json["token_type"]! as String,
      accessToken: json["access_token"]! as String,
      expiresIn: json["expires_in"]! as int,
      refreshToken: json["refresh_token"]! as String,
    );
  }
}
