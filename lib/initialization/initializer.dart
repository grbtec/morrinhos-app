import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/initialization/deep_link_settings_initializer.dart';
import 'package:mobile/initialization/layout_initializer.dart';
import 'package:mobile/initialization/user_initializer.dart';
import 'package:timeago/timeago.dart' as timeago;

class Initializer extends ConsumerStatefulWidget {
  final Widget splashScreen;
  final VoidCallback onComplete;

  const Initializer({
    super.key,
    required this.splashScreen,
    required this.onComplete,
  });

  @override
  ConsumerState<Initializer> createState() => _InitializerState();
}

class _InitializerState extends ConsumerState<Initializer> {
  final initializersCompleter = Completer();

  @override
  void initState() {
    super.initState();
    final futures = <Future<void>>[initializersCompleter.future];
    futures.add(UserInitializer().initialize(ref));
    futures.add(Future(
      () => timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages()),
    ));
    futures.add(DeepLinkSettingsInitializer().initialize(ref));
    if(kDebugMode){
      futures.add(Future.delayed(const Duration(seconds: 1)));
    }

    if(kDebugMode){
      futures.forEach((element) async {
        final index = futures.indexOf(element);
        await element;
        print("[DEBUG] Initializer future $index completed");
      });
    }
    final tasksFuture = Future.wait(futures);
    tasksFuture.whenComplete(widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return _MultiInitializer.constructors(
      onComplete: initializersCompleter.complete,
      constructors: const [
        LayoutInitializer.new,
      ],
      child: widget.splashScreen,
    );
  }
}

class _MultiInitializer extends StatelessWidget {
  final List<Widget Function(VoidCallback onComplete, Widget)> builders;
  final Widget child;
  final VoidCallback onComplete;

  const _MultiInitializer({
    required this.onComplete,
    required this.builders,
    required this.child,
  });

  _MultiInitializer.constructors({
    required this.onComplete,
    required List<
            Widget Function(
                {required VoidCallback onComplete, required Widget child})>
        constructors,
    required this.child,
  }) : builders = constructors.map((constructor) {
          return (VoidCallback onComplete, Widget child) {
            return constructor(onComplete: onComplete, child: child);
          };
        }).toList();

  Widget buildInitializer({required VoidCallback onComplete, int index = 0}) {
    if (index == builders.length) {
      onComplete();
      return child;
    }
    final initializerCompleter = Completer();
    void nestedOnComplete() async {
      await initializerCompleter.future;
      if (kDebugMode) {
        print("[DEBUG] Nested initializer $index completed");
      }
      onComplete();
    }

    void middleware() async {
      initializerCompleter.complete();
    }
    return builders[index](
      middleware,
      buildInitializer(
        onComplete: nestedOnComplete,
        index: index + 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildInitializer(onComplete: onComplete);
  }
}
