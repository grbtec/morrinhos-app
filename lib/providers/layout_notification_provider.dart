import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/repositories/widget_repository.dart';

final layoutNotificationProvider = FutureProvider.family(
  (ref, String id) {
    return ref
        .read(layoutRepositoryProvider)
        .getLayoutNotification(id)
        .then((result) => result.asFuture);
  },
);
