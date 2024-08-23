import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/initialization/initializer.dart';
import 'package:mobile/my_app.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';
import 'package:mobile/splash_screen.dart';

Future<void> main({
  List<Override> overrideList = const [],
  List<NavigatorObserver> navigatorObservers = const [],
}) async {
  final completer = Completer();
  runApp(
    ProviderScope(
      overrides: overrideList,
      child: Consumer(
        builder: (context, ref, _) {
          final tenantSlugAsync = ref.watch(tenantSlugProvider);
          if (tenantSlugAsync.valueOrNull == null) {
            return const SplashScreen();
          }
          return Initializer(
            splashScreen: const SplashScreen(),
            onComplete: () {
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          );
        },
      ),
    ),
  );
  Future.delayed(const Duration(seconds: 3), () {
    if (!completer.isCompleted) {
      completer.complete();
      if (kDebugMode) {
        print("!!!!!!!!!!!!\n"
            "Initialization lasted more than 3 seconds\n"
            "!!!!!!!!!!!!");
      }
    }
  });
  await completer.future;
  runApp(
    ProviderScope(
      overrides: overrideList,
      child: MyApp(
        navigatorObservers: navigatorObservers,
      ),
    ),
  );
}
