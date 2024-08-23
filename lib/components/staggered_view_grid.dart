import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:mobile/components/special_widget.dart';
import 'package:mobile/components/widget_tile.dart';
import 'package:mobile/model/layout_special_widget_model.dart';
import 'package:mobile/model/layout_view_widget.dart';
import 'package:mobile/providers/layout_notification_provider.dart';
import 'package:mobile/providers/layout_widget_provider.dart';
import 'package:mobile/repositories/widget_repository.dart';

class StaggeredViewGrid extends ConsumerStatefulWidget {
  const StaggeredViewGrid({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StaggeredViewGrid();
}

class _StaggeredViewGrid extends ConsumerState<StaggeredViewGrid> {
  void setWidgetNotification(String id) {
    ref.watch(layoutRepositoryProvider).setLayoutNotification(id);
    ref.invalidate(layoutNotificationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final layoutAsync = ref.watch(layoutProvider);
    final layout = layoutAsync.valueOrNull;
    ref.listen(layoutProvider, (previous, next) {
      if (next.hasError) {
        final layoutError = layoutAsync.error!;
        final errorMessage = layoutError is ErrorResult
            ? layoutError.error.toString()
            : "Erro desconhecido";
        FluentToast(
          text: FluentText(errorMessage),
        ).show(context: context);
        if (kDebugMode && layoutError is! ErrorResult) {
          Future.microtask(()=>throw layoutError);
        }
      }
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          if (layoutAsync.isLoading) const FluentProgressBar(value: null),
          if (layoutAsync.hasError)
            Builder(
              builder: (context) {
                final layoutError = layoutAsync.error!;
                final errorMessage = layoutError is ErrorResult
                    ? layoutError.error.toString()
                    : "Erro desconhecido";
                if (kDebugMode && layoutError is! ErrorResult) {
                  Future.microtask(()=>throw layoutError);
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: FluentSize.size120.value),
                    const Icon(
                      FluentIcons.error_circle_12_filled,
                      color: FluentColors.neutralBackground2Pressed,
                      size: 40,
                    ),
                    SizedBox(height: FluentSize.size120.value),
                    FluentText(
                      errorMessage,
                      style: FluentThemeDataModel.of(context)
                          .fluentTextTheme
                          ?.body1
                          ?.fluentCopyWith(
                            fluentColor: FluentColors.neutralForeground2Rest,
                          ),
                    ),
                    SizedBox(height: FluentSize.size160.value),
                    FluentButton(
                      variant: FluentButtonVariant.outline,
                      title: "Tentar Novamente",
                      onPressed: () => ref.invalidate(layoutProvider),
                    )
                  ],
                );
              },
            ),
          if (layout != null)
            Builder(
              builder: (context) {
                final tiles = layout.tiles;
                return Padding(
                  padding: EdgeInsets.all(
                    FluentSize.size160.value,
                  ),
                  child: StaggeredGrid.count(
                    key: ValueKey(layoutAsync.hasError),
                    crossAxisCount: 4,
                    mainAxisSpacing: FluentSize.size160.value,
                    crossAxisSpacing: FluentSize.size160.value,
                    children: [
                      for (var i = 0; i < tiles.length; i++)
                        Consumer(
                          builder: (context, ref, child) {
                            final layoutWidgetAsync = ref.watch(
                                layoutWidgetProvider(tiles[i].widget.id));

                            final layoutWidget = layoutWidgetAsync.valueOrNull;

                            final notificationValueAsync = ref.watch(
                              layoutNotificationProvider(tiles[i].widget.id),
                            );

                            final notificationValue =
                                notificationValueAsync.valueOrNull;

                            if (layoutWidget != null) {
                              return switch (layoutWidget) {
                                LayoutViewWidget() => ViewWidgetTile(
                                    key: Key('$i-widgetView'),
                                    notificationValue: notificationValue,
                                    backgroundColor:
                                        layoutWidget.backgroundColor?.transform(
                                      (color) => Color(
                                        color | 0xFF000000,
                                      ),
                                    ),
                                    route: layoutWidget.route,
                                    iconName: layoutWidget.iconName,
                                    title: layoutWidget.title,
                                    backgroundImageUrl:
                                        layoutWidget.backgroundImageUrl,
                                    onTap: () {
                                      setWidgetNotification(tiles[i].widget.id);
                                    },
                                    width: tiles[i].width,
                                    height: tiles[i].height,
                                  ),
                                LayoutSpecialWidget() => SpecialWidgetTile(
                                    key: i == 2
                                        ? const Key('2-widgetSpecial')
                                        : null,
                                    width: tiles[i].width,
                                    height: tiles[i].height,
                                    layoutWidget:
                                        layoutWidget as LayoutSpecialWidget,
                                  ),
                                _ => throw "Invalid variant",
                              };
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
