import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:mobile/theme.dart';

// See https://flutterwings.dev/
Widget buildPreview(BuildContext context, Widget child){
  return ProviderScope(
    child: FluentProvider( 
      child:MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
      home: child
    ),),
  );
}