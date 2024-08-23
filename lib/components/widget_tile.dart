import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/infrastructure/icons_view.dart';

class ViewWidgetTile extends StatelessWidget {
  final int width;
  final int height;
  final String route;
  final String? iconName;
  final String title;
  final String? backgroundImageUrl;
  final Color? backgroundColor;
  final bool isLoading;
  final void Function()? onTap;
  final int? notificationValue;

  const ViewWidgetTile({
    super.key,
    this.onTap,
    this.iconName,
    this.backgroundColor,
    this.backgroundImageUrl,
    required this.title,
    required this.route,
    required this.width,
    required this.height,
    this.isLoading = false,
    this.notificationValue,
  }) : assert(backgroundImageUrl != null || backgroundColor != null);

  @override
  Widget build(BuildContext context) {
    final colorMode = createColorMode(Theme.of(context).brightness);
    const iconTable = IconView.iconTable;

    final onTap = this.onTap;
    final backgroundImageUrl = this.backgroundImageUrl;

    return StaggeredGridTile.count(
      crossAxisCellCount: width,
      mainAxisCellCount: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) const FluentProgressBar(value: null),
          Expanded(
            child: Stack(
              children: [
                if (backgroundColor != null)
                  FluentContainer(
                    color: backgroundColor,
                    cornerRadius: FluentCornerRadius.large,
                  ),
                if (backgroundImageUrl != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(FluentCornerRadius.large.value),
                    child: Image.network(
                      backgroundImageUrl,
                      fit: BoxFit.cover,
                      width: double.maxFinite,
                      height: double.maxFinite,
                    ),
                  ),
                FluentContainer(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  padding: EdgeInsets.all(FluentSize.size100.value),
                  child: Icon(
                    iconTable[iconName],
                    color: FluentColors.neutralBackground1Rest,
                    size: width > 1 || height > 1 ? 70 : 30,
                  ),
                ),
                if (width > 1 || height > 1)
                  Positioned(
                    left: FluentSize.size120.value,
                    bottom: FluentSize.size120.value,
                    child: FluentText(
                      title,
                      style: FluentThemeDataModel.of(context)
                          .fluentTextTheme
                          ?.body2
                          ?.fluentCopyWith(
                              fluentColor: FluentColors.neutralBackground1Rest,
                              fluentWeight: FluentFontWeight.semibold),
                    ),
                  ),
                if (notificationValue != null && notificationValue != 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: const Offset(5, -5),
                      child: FluentAvatar(
                        size: FluentAvatarSize.size24,
                        strokeStyle: FluentStrokeStyle(
                          color: colorMode(FluentColors.neutralBackground1Rest,
                              FluentDarkColors.neutralBackground1Rest),
                          thickness: FluentStrokeThickness.strokeWidth30,
                        ),
                        child: FluentContainer(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          alignment: Alignment.center,
                          color: Colors.red,
                          child: FluentText(
                            notificationValue.toString(),
                            textAlign: TextAlign.center,
                            style: FluentThemeDataModel.of(context)
                                .fluentTextTheme
                                ?.caption1Strong
                                ?.fluentCopyWith(fluentColor: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap();
                    }
                    context.pushNamed(route);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
