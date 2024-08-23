import 'package:flutter/widgets.dart';

import 'simple_controller.dart';

abstract class ViewController<TState extends State> implements SimpleController{
  final TState state;
  const ViewController(this.state);
}