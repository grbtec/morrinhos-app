import 'package:flutter/material.dart';

/// V8 BlocBuilder
class BlocBuilder<TState> extends StatelessWidget {
  final dynamic bloc;
  final Widget Function(BuildContext context, TState state) builder;

  /// V8 BlocBuilder
  const BlocBuilder({super.key, required this.bloc, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: bloc.state as TState,
        stream: bloc.stream as Stream<TState>,
        builder: (context, snapshot) {
          return builder(context, snapshot.data as TState);
        });
  }
}
