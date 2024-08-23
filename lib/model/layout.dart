
import 'package:gbt_essentials/gbt_dart_essentials.dart';

class Layout {
  final List<LayoutTile> tiles;

  const Layout({
    required this.tiles,
  });

  factory Layout.fromJson(Map<String, Object?> json) => Layout(
        tiles: (json["tiles"] as List<dynamic>)
            .cast<Map<String, Object?>>()
            .map((e) => LayoutTile.fromJson(e))
            .toList(),
      );

  Map<String, Object?> toFormJson() => {
        "tiles": tiles.map((tile) => tile.toFormJson()).toList(),
      };
}

class LayoutTile {
  final int width;
  final int height;
  final IdHolder widget;

  const LayoutTile({
    required this.width,
    required this.height,
    required this.widget,
  });

  factory LayoutTile.fromJson(Map<String, dynamic> json) => LayoutTile(
        width: json["width"] as int,
        height: json["height"] as int,
        widget: IdHolder.fromJson(json["widget"]! as Map<String, Object?>),
      );

  Map<String, Object?> toFormJson() => {
        "width": width,
        "height": height,
        "widgetId": widget.id,
      };
}

// class LayoutTileWidget {
//   final String variant;
//
//   LayoutTileWidget({
//     required this.variant,
//   });
//
//   factory LayoutTileWidget.fromJson(Map<String, dynamic> json) =>
//       LayoutTileWidget(
//         variant: json["variant"].toString(),
//       );
// }
