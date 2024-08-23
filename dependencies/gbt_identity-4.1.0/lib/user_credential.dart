import 'package:gbt_identity/authenticated_user.dart';
import 'package:gbt_identity/user_tokens.dart';

class UserCredential<T extends AuthenticatedUser> {
  final T user;
  UserTokens _tokens;
  final Future<UserTokens?> Function()? renewTokens;
  final bool isAnonymous;

  UserCredential({
    required this.user,
    required UserTokens tokens,
    required this.renewTokens,
    this.isAnonymous = false,
  }) : _tokens = tokens;

  String? get tokenType => _tokens.tokenType;

  Future<String> getAccessToken() async =>
      (await getValidUserTokens()).accessToken;

  Future<String> getIdToken() async => (await getValidUserTokens()).idToken;

  Future<UserTokens> getValidUserTokens() async {
    final renewTokens = this.renewTokens;
    if (renewTokens == null) {
      return _tokens;
    } else {
      if (DateTime.now().millisecondsSinceEpoch <
          _tokens.expiresAt
              .subtract(Duration(minutes: 1))
              .millisecondsSinceEpoch) {
        return _tokens;
      } else {

        final renewedTokens = await renewTokens();
        if (renewedTokens == null) {
          return _tokens;
        } else {
          _tokens = UserTokens(
              idToken: renewedTokens.idToken.isNotEmpty
                  ? renewedTokens.idToken
                  : _tokens.idToken,
              accessToken: renewedTokens.accessToken.isNotEmpty
                  ? renewedTokens.accessToken
                  : _tokens.accessToken,
              expiresAt: renewedTokens.expiresAt,
              tokenType: renewedTokens.tokenType ?? _tokens.tokenType);

          return _tokens;
        }
      }
    }
  }
}
