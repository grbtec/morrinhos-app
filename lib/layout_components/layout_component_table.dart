
import 'package:flutter/material.dart';

import 'layout_clock.dart';

class LayoutComponentTable {
  static Map<String, WidgetBuilder> get instance => {"LayoutClock": (_)=>const LayoutClock()};
}
