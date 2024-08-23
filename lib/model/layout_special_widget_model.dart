
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:mobile/model/layout_widget_variant.dart';

class LayoutSpecialWidget implements Variant<LayoutWidgetVariant> {
  @override
  LayoutWidgetVariant get variant => LayoutWidgetVariant.special;
  final String? componentName;
  final String? backgroundImageUrl;
  final int? backgroundColor;

  LayoutSpecialWidget({
    required this.componentName,
    required this.backgroundColor,
    required this.backgroundImageUrl,
  });

  factory LayoutSpecialWidget.fromJson(Map<String, Object?> json) {
    assert(json["componentName"] is String?);
    assert(json["backgroundImageUrl"] is String?);
    assert(json["backgroundColor"] is int?);
    return LayoutSpecialWidget(
      componentName: json["componentName"] as String?,
      backgroundImageUrl: json["backgroundImageUrl"] as String?,
      backgroundColor: json["backgroundColor"] as int?,
    );
  }
}