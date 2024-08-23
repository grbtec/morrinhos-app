import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/infrastructure/events/event_bus.dart';
import 'package:mobile/infrastructure/events/need_update_event.dart';
import 'package:mobile/updating_view.dart';

class MyAppViewBuilder extends StatefulWidget {
  final Widget? child;

  const MyAppViewBuilder({super.key, required this.child});

  @override
  State<MyAppViewBuilder> createState() => _MyAppViewBuilderState();
}

class _MyAppViewBuilderState extends State<MyAppViewBuilder> {
  StreamSubscription? needUpdateSubscription;
  bool needUpdate = false;

  @override
  void initState() {
    super.initState();
    needUpdateSubscription =
        MyEventBus.instance.on<NeedUpdateEvent>().listen((event) {
      setState(() {
        needUpdate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(needUpdate){
      return const UpdatingView();
    }

    return widget.child ??
        const Scaffold(
          body: Center(child: Text("Feche o aplicativo e abra novamente.")),
        );
  }

  @override
  void dispose() {
    needUpdateSubscription?.cancel();
    super.dispose();
  }
}
