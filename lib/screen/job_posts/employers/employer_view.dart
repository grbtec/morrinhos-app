
import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';

class EmployerView extends StatelessWidget {
  final String id;
  const EmployerView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavLeftSubtitle(
          title: "Employer",
          subtitle: "Employer",
        ),
      ),
      body: Text(id),
    );
  }
}
