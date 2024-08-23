import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';

class UpdatingView extends StatelessWidget {
  const UpdatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FluentNavBar(
        title: NavCenterTitle(
          title: "Atualize o aplicativo"
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Esta versão não é mais compatível."),
            Text("Por favor, atualize o aplicativo.")
          ],
        ),
      ),
    );
  }
}
