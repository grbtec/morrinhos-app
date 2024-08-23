import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:mobile/providers/deep_link_settings_provider.dart';
import 'package:share_plus/share_plus.dart';

final shareServiceProvider = Provider.autoDispose((ref) => ShareService(
      deepLinkSettings: ref.watch(deepLinkSettingsProvider).requireValue,
    ));

class ShareService {
  final DeepLinkSettings deepLinkSettings;

  ShareService({
    required this.deepLinkSettings,
  });

  void shareResource(String title, ResourceType resourceType, String resourceId) {
    final route = deepLinkSettings.routesMap[resourceType.name] ??
        resourceType.fallbackDeepLinkRoute;
    final uri =
        Uri.parse(deepLinkSettings.baseUrl).appendPath("/$route/$resourceId");
    Share.share(
      "$title\n$uri",
      subject: title,
    );
  }
}

enum ResourceType {
  post,
  // employer,
  // jobVacancy,
  // jobPost,
  // publicUtility,
}

extension ResourceTypeExtension on ResourceType {
  String get fallbackDeepLinkRoute {
    return switch (this) {
      ResourceType.post => "p",
    };
  }
}
