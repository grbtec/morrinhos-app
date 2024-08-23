import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/deep_link_settings_provider.dart';

class DeepLinkSettingsInitializer {
  DeepLinkSettingsInitializer();

  Future<void> initialize(WidgetRef ref) async{
    ref.read(deepLinkSettingsProvider);
  }

}
