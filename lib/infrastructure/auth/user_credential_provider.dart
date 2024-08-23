import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_identity/registered_user.dart';
import 'package:gbt_identity/token_repository.dart';
import 'package:gbt_identity/user_credential.dart';
import 'package:gbt_identity/user_tokens.dart';
import 'package:mobile/infrastructure/auth/app_user_dto.dart';
import 'package:mobile/infrastructure/auth/auth_service.dart';
import 'package:mobile/infrastructure/auth/secure_token.dart';
import 'package:mobile/infrastructure/auth/secure_token_repository.dart';

final userCredentialProvider = AsyncNotifierProvider<
    AsyncUserCredentialNotifier, UserCredential<RegisteredUser>?>(
  () => AsyncUserCredentialNotifier(),
);

class AsyncUserCredentialNotifier
    extends AsyncNotifier<UserCredential<RegisteredUser>?> {
  TokenRepository get _tokenRepository =>
      ref.read(secureTokenRepositoryProvider);

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  FutureOr<UserCredential<RegisteredUser>?> build() async {
    final secureToken = await loadSecureToken();
    if (secureToken == null) {
      return null;
    }
    final userCredentialResult = await _createUserCredential(
      () async => Result.value(UserTokens(
        idToken: "",
        accessToken: "",
        expiresAt: DateTime.now(),
        tokenType: "None",
      )),
      (_) async => Result.value(secureToken.user),
    );

    return userCredentialResult.asFuture;
  }

  Future<SecureToken<RegisteredUser>?> loadSecureToken() async {
    final token = await _tokenRepository.loadToken();
    if (token == null) {
      return null;
    }
    return SecureToken.fromJson(
      jsonDecode(token)! as Map<String, Object?>,
      AppUserDto.fromJson,
    );
  }

  Future<Result<UserCredential<RegisteredUser>>> _createUserCredential(
    Future<Result<UserTokens>> Function() getUserTokens,
    Future<Result<RegisteredUser>> Function(UserTokens userTokens) getUser,
  ) async {
    try {
      final userTokensResult = await getUserTokens();
      if (userTokensResult.isError) {
        return Result.error(userTokensResult.asError!.error);
      }
      final userTokens = userTokensResult.asValue!.value;

      final userResult = await getUser(userTokens);
      if (userResult.isError) {
        return Result.error(userResult.asError!.error);
      }
      final user = userResult.asValue!.value;

      final userCredential = UserCredential(
        user: user,
        tokens: userTokens,
        renewTokens: _getRenewTokensFunction(user),
      );
      return Result.value(userCredential);
    } catch (error) {
      return Result.error(error);
    }
  }

  Future<UserTokens?> Function() _getRenewTokensFunction(RegisteredUser user) {
    return () async {
      final secureToken = await loadSecureToken();
      if (secureToken == null) {
        return null;
      }
      final refreshToken = secureToken.refreshToken;
      final result = await _authService.renew(refreshToken);
      if (result.isError) {
        throw result.asError!.error;
      }
      final newTokens = result.asValue!.value;
      final userTokens = _toUserTokens(newTokens);
      unawaited(Future(() async {
        final newUser = await _authService
            .getMe(userTokens)
            .catchError((_) async => Result.value(user));
        try {
          await _tokenRepository.storeToken(
            jsonEncode(SecureToken(
              user: newUser.asValue?.value ?? user,
              refreshToken: newTokens.refreshToken,
            )),
          );
        } finally {
          await _authService.revoke(refreshToken);
        }
      }));
      return userTokens;
    };
  }

  UserTokens _toUserTokens(AspNetTokenResponse aspNetTokenResponse) {
    return UserTokens(
      idToken: "",
      accessToken: aspNetTokenResponse.accessToken,
      expiresAt:
          DateTime.now().add(Duration(seconds: aspNetTokenResponse.expiresIn)),
      tokenType: aspNetTokenResponse.tokenType,
    );
  }

  Future<Result<UserCredential<RegisteredUser>>> signIn(
      String username, String password) async {
    final tokenResponseResult = await _authService.signIn(username, password);
    if (tokenResponseResult.isError) {
      return Result.error(tokenResponseResult.asError!.error);
    }
    final tokenResponse = tokenResponseResult.asValue!.value;
    final userCredentialResult = await _createUserCredential(
      () async => Result.value(_toUserTokens(tokenResponse)),
      (userTokens) => _authService.getMe(userTokens),
    );
    if (userCredentialResult.isError) {
      return Result.error(userCredentialResult.asError!.error);
    }
    final userCredential = userCredentialResult.asValue!.value;
    final secureToken = SecureToken(
      user: userCredential.user,
      refreshToken: tokenResponse.refreshToken,
    );
    await _tokenRepository.storeToken(jsonEncode(secureToken));
    state = AsyncData(userCredential);
    return Result.value(userCredential);
  }

  Future<Result<void>> signOut() async {
    final secureToken = await loadSecureToken();
    if (secureToken == null) {
      return Result.value(null);
    }
    final refreshToken = secureToken.refreshToken;
    final result = await _authService.revoke(refreshToken);
    if (result.isError) {
      return Result.error(result.asError!.error);
    }
    await _tokenRepository.removeToken();
    state = const AsyncData(null);
    return Result.value(null);
  }
}
