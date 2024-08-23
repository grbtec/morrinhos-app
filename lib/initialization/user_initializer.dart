import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_identity/registered_user.dart';
import 'package:gbt_identity/user_credential.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';

class UserInitializer {
  UserInitializer();

  ///
  Future<void> initialize(WidgetRef ref) async{
    late final ProviderSubscription<AsyncValue<UserCredential<RegisteredUser>?>>
        sub;
    final userCredentialNotifier = ref.read(userCredentialProvider.notifier);
    sub = ref.listenManual(userCredentialProvider, (previous, next) async{
      if (!next.isLoading) {
        sub.close();
        final userCredential = next.valueOrNull;
        if (userCredential != null) {
          try{
            await userCredential.getValidUserTokens();
          }catch(error){
            if(error is HttpError){
              await userCredentialNotifier.signOut();
            }
          }
        }
      }
    });
  }

}
