import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_fluent2_ui/theme_data.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/my_app_view_builder.dart';
import 'package:mobile/screen/home/home_view.dart';

class MyApp extends StatelessWidget {
  final List<NavigatorObserver> navigatorObservers;

  MyApp({
    super.key,
    this.navigatorObservers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FluentProvider(
      child: MaterialApp.router(
        title: 'City Guide --',
        theme: theme,
        routerConfig: router,
        darkTheme: darkTheme,
        builder: (context, child) {
          return MyAppViewBuilder(child: child);
        },
      ),
    );
  }
}

class NavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print("didPush: $route | $previousRoute");
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print("didReplace: $newRoute | $oldRoute");
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
