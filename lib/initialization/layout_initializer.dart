import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/layout_widget_provider.dart';

class LayoutInitializer extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final Widget child;

  const LayoutInitializer({
    required this.onComplete,
    required this.child,
  });

  @override
  ConsumerState<LayoutInitializer> createState() => _LayoutInitializerState();
}

class _LayoutInitializerState extends ConsumerState<LayoutInitializer> {
  final providersSubscriptions = <ProviderSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    _initAsync().whenComplete(widget.onComplete);
  }

  Future<void> _initAsync() async {
    providersSubscriptions.add(
      // Keep subscription
      ref.listenManual(layoutProvider, providerListener),
    );
    // First load the hardcoded and discard it
    await ref.read(layoutProvider.future);
    final layout = await ref.read(layoutProvider.future);

    for (final tile in layout.tiles) {
      providersSubscriptions.add(
        // Keep subscription
        ref.listenManual(
          layoutWidgetProvider(tile.widget.id),
          providerListener,
        ),
      );
    }
    await Future.wait([
      for (final tile in layout.tiles)
        ref.read(layoutWidgetProvider(tile.widget.id).future),
    ]);
  }

  void providerListener(Object? previous, Object? next) {
    // Do absolutely nothing
    // Only holding the dependent ir order to deny provider disposing
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    Future.delayed(const Duration(seconds: 5)).whenComplete(() {
      for (final sub in providersSubscriptions) {
        sub.close();
      }
    });
    super.dispose();
  }
}
