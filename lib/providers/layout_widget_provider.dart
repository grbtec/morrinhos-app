import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/model/layout.dart';
import 'package:mobile/model/layout_view_widget.dart';
import 'package:mobile/repositories/widget_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final layoutProvider = FutureProvider.autoDispose((ref) async {
  if (ref.state.valueOrNull == null) {
    ref.listenSelf((previous, next) {
      if (previous?.hasValue == false) {
        ref.invalidateSelf();
      }
    });
    return _hardCodedLayout;
  }
  final useCache = ref.swr() || ref.state.valueOrNull == _hardCodedLayout;
  final value = await ref
      .read(layoutRepositoryProvider)
      .getDefaultLayout(useCache: useCache)
      .unwrapOrThrowResult();
  return value ?? _hardCodedLayout;
});

final layoutWidgetProvider = FutureProvider.family.autoDispose(
  (ref, String id) async {
    if (_hardCodedWidgets.containsKey(id)) {
      return _hardCodedWidgets[id]!;
    }
    final useCache = ref.swr();
    final value = await ref
        .read(layoutRepositoryProvider)
        .getLayoutWidget(id, useCache: useCache)
        .unwrapOrThrowResult();
    return value;
  },
);

const _hardCodedLayout = Layout(
  tiles: [
    LayoutTile(
      width: 4,
      height: 2,
      widget: IdHolder(id: "hard_coded_job_posts"),
    ),
    LayoutTile(
      width: 2,
      height: 2,
      widget: IdHolder(id: "hard_coded_public_utility"),
    ),
    LayoutTile(
      width: 2,
      height: 2,
      widget: IdHolder(id: "hard_coded_global_search"),
    ),
  ],
);

const _hardCodedWidgets = {
  "hard_coded_job_posts": LayoutViewWidget(
    title: "Vagas de emprego",
    route: Routes.jobPosts,
    iconName: "handshake_20_filled",
    backgroundImageUrl: null,
    backgroundColor: 0XFF0F6CBD,
  ),
  "hard_coded_public_utility": LayoutViewWidget(
    title: "Utilidade pública",
    route: Routes.publicUtility,
    iconName: "book_20_filled",
    backgroundImageUrl: null,
    backgroundColor: 0XFF0F6CBD,
  ),
  "hard_coded_global_search": LayoutViewWidget(
    title: "Buscar",
    route: Routes.search,
    iconName: "search_20_filled",
    backgroundImageUrl: null,
    backgroundColor: 0XFF0F6CBD,
  ),
};
