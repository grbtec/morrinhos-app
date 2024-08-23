import 'package:gbt_essentials/gbt_dart_essentials.dart';

interface class LayoutWidgetVariant extends Enumeration{
  static const LayoutWidgetVariant view = LayoutWidgetVariant(0,"View");
  static const LayoutWidgetVariant special = LayoutWidgetVariant(1,"Special");

  const LayoutWidgetVariant(super.id, super.name);
}