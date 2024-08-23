import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      body: FluentContainer(
        alignment: Alignment.center,
        child: Column(
          children: [
            FluentText("Splash Screen"),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
