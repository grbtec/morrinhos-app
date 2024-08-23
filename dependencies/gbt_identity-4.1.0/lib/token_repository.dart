abstract interface class TokenRepository{
  Future<String?> loadToken();

  Future<void> storeToken(String token);
  
  Future<void> removeToken();
}