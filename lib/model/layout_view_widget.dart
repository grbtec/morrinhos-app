import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:mobile/model/layout_widget_variant.dart';

class LayoutViewWidget implements Variant<LayoutWidgetVariant> {
  @override
  LayoutWidgetVariant get variant => LayoutWidgetVariant.view;
  final String route;
  final String title;
  final String? iconName;
  final String? backgroundImageUrl;
  final int? backgroundColor;

  const LayoutViewWidget({
    required this.title,
    required this.route,
    required this.iconName,
    required this.backgroundImageUrl,
    required this.backgroundColor,
  });

  factory LayoutViewWidget.fromJson(Map<String, Object?> json) {
    assert(json["title"] is String);
    assert(json["route"] is String);
    assert(json["iconName"] is String?);
    assert(json["backgroundImageUrl"] is String?);
    assert(json["backgroundColor"] is int?);
    return LayoutViewWidget(
      title: json["title"]! as String,
      route: json["route"]! as String,
      iconName: json["iconName"] as String?,
      backgroundImageUrl: json["backgroundImageUrl"] as String?,
      backgroundColor: json["backgroundColor"] as int?,
    );
  }
}
