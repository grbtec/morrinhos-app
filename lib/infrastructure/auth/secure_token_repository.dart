import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gbt_identity/token_repository.dart';

final secureTokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => SecureTokenRepository(),
);

class SecureTokenRepository implements TokenRepository {
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  String get _secureStorageKey => "secure_token";

  @override
  Future<String?> loadToken() {
    return secureStorage.read(key: _secureStorageKey);
  }

  @override
  Future<void> removeToken() async {
    await secureStorage.delete(key: _secureStorageKey);
  }

  @override
  Future<void> storeToken(String token) async {
    await secureStorage.write(key: _secureStorageKey, value: token);
  }
}
