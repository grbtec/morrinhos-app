import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:mobile/infrastructure/special_components.dart';
import 'package:mobile/model/layout_special_widget_model.dart';

class SpecialWidgetTile extends StatelessWidget {
  final int width;
  final int height;
  final bool isLoading;
  final LayoutSpecialWidget layoutWidget;

  const SpecialWidgetTile({
    super.key,
    required this.width,
    required this.height,
    this.isLoading = false,
    required this.layoutWidget,
  });

  @override
  Widget build(BuildContext context) {
    final componentName = layoutWidget.componentName;
    final backgroundColor = layoutWidget.backgroundColor;
    final backgroundImageUrl = layoutWidget.backgroundImageUrl;

    final component = SpecialComponents.table[componentName];

    return StaggeredGridTile.count(
      crossAxisCellCount: width,
      mainAxisCellCount: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) const FluentProgressBar(value: null),
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(FluentCornerRadius.large.value),
              child: Stack(
                children: [
                  if (backgroundColor != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Color(
                          backgroundColor | 0xFF000000,
                        ),
                      ),
                    ),
                  if (backgroundImageUrl != null)
                    Positioned.fill(
                      child: Image.network(backgroundImageUrl),
                    ),
                  if (component != null)
                    Padding(
                      padding: EdgeInsets.all(FluentSize.size20.value),
                      child: component,
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
