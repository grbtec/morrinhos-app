import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/application_core/controllers/riverpod_paged_list_controller.dart';
import 'package:mobile/components/error_component.dart';
import 'package:mobile/components/my_paged_child_builder_delegate.dart';
import 'package:mobile/model/geo_location_coordinates.dart';
import 'package:mobile/model/public_utility_body.dart';
import 'package:mobile/providers/public_utilities_bodies_providers.dart';
import 'package:mobile/services/launch_service.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final _pairItemsPagedListProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) async {
  final pagedList =
      await ref.watch(pagedPublicUtilityBodiesProvider(params).future);
  final pairItemsPagedList = PagedList.raw(
    currentPage: pagedList.currentPage,
    pageSize: pagedList.pageSize,
    results: pagedList.results
        .map((item) {
          final index = pagedList.results.indexOf(item);
          if (index % 2 != 0) {
            return null;
          }
          final nextItem = pagedList.results.elementAtOrNull(index + 1);
          return (item, nextItem);
        })
        .where((element) => element != null)
        .cast<(IdHolder, IdHolder?)>()
        .toList(),
  );
  return pairItemsPagedList;
});

class PublicUtilityView extends ConsumerStatefulWidget {
  const PublicUtilityView({super.key});

  @override
  ConsumerState<PublicUtilityView> createState() => _PublicUtilityViewState();
}

class _PublicUtilityViewState extends ConsumerState<PublicUtilityView> {
  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavLeftTitle(
          title: "Utilidade pública",
        ),
      ),
      body: _PagedList(),
    );
  }
}

class _PagedList extends ConsumerStatefulWidget {
  final String? search;

  const _PagedList({
    super.key,
    this.search,
  });

  @override
  ConsumerState<_PagedList> createState() => __PagedListState();
}

class __PagedListState extends ConsumerState<_PagedList> {
  late final pagedListController = RiverpodPagedListController(
    this,
    _pairItemsPagedListProvider,
    search: widget.search,
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, (IdHolder, IdHolder?)>.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      pagingController: pagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
        controller: pagedListController.pagingController,
        itemBuilder: (BuildContext context, items, int index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: index == 0 ? 16 : 0,
            ),
            child: Row(
              children: [
                Expanded(child: _Item(id: items.$1.id, leftSide: true)),
                const SizedBox(width: 12),
                Expanded(
                  child: items.$2?.id
                          .transform((id) => _Item(id: id, leftSide: false)) ??
                      Container(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Item extends ConsumerWidget {
  final String id;
  final bool leftSide;

  const _Item({
    super.key,
    required this.id,
    required this.leftSide,
  });

  Widget _popoverOption({
    required Widget icon,
    required String text,
    required VoidCallback onClick,
  }) {
    return MaterialButton(
      onPressed: onClick,
      visualDensity: VisualDensity.compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8, height: 8),
          FluentText(text),
        ],
      ),
    );
  }

  void launch(
      BuildContext context, PublicUtilityBodyLinkType type, String value) {
    final launchType = switch (type) {
      PublicUtilityBodyLinkType.geo => null,
      _ => LaunchType.url,
    };
    if (launchType == null) {
      if (type == PublicUtilityBodyLinkType.geo) {
        final geoRegex = RegExp(
            r"geo:(?<latitude>-?\d+(?:\.\d+)?),(?<longitude>-?\d+(?:\.\d+)?)");
        final match = geoRegex.firstMatch(value);
        final latitude = match?.namedGroup("latitude");
        final longitude = match?.namedGroup("longitude");
        if (match == null || latitude == null || longitude == null) {
          FluentToast(
            text: FluentText("Informações de localização inválidas"),
          ).show(context: context);
          return;
        }
        LaunchService().launchMap(GeoLocationCoordinates.raw(
          latitude: double.parse(latitude),
          longitude: double.parse(longitude),
        ));
      }
      return;
    }
    LaunchService().launch(launchType, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicUtilityBodyAsync = ref.watch(publicUtilityBodyProvider(id));
    final publicUtilityBody = publicUtilityBodyAsync.valueOrNull;
    final errorResult = publicUtilityBodyAsync.errorResult;
    final location = publicUtilityBody?.location;
    return Column(
      children: [
        Stack(
          fit: StackFit.passthrough,
          children: [
            if (publicUtilityBody != null)
              FluentCard(
                coverImage: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        publicUtilityBody.coverImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: FluentCardContainer(
                        width: 28,
                        height: 28,
                        child: FluentPopover(
                          // controller: popOverController,
                          axis: leftSide ? Axis.vertical : Axis.horizontal,
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FluentText(publicUtilityBody.name),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final link in [
                                  ...publicUtilityBody.links,
                                  if (location != null)
                                    PublicUtilityBodyLink.raw(
                                      title: "Ver no mapa",
                                      actionText: "Ver no mapa",
                                      linkType: PublicUtilityBodyLinkType.geo,
                                      actionUri:
                                          "geo:${location.latitude},${location.longitude}",
                                    ),
                                ])
                                  _popoverOption(
                                    text: link.title,
                                    icon: switch (link.linkType) {
                                      PublicUtilityBodyLinkType.phone =>
                                        const Icon(
                                            FluentIcons.phone_24_regular),
                                      PublicUtilityBodyLinkType.email =>
                                        const Icon(FluentIcons.mail_24_regular),
                                      PublicUtilityBodyLinkType.geo =>
                                        const Icon(
                                            FluentIcons.location_24_regular),
                                      PublicUtilityBodyLinkType.url =>
                                        const Icon(
                                            FluentIcons.globe_24_regular),
                                      PublicUtilityBodyLinkType.whatsApp =>
                                        const Icon(
                                            FluentIcons.phone_chat_16_regular),
                                      PublicUtilityBodyLinkType.other =>
                                        const Icon(FluentIcons.link_24_regular),
                                      _ =>
                                        const Icon(FluentIcons.link_24_regular),
                                    },
                                    onClick: () => launch(
                                      context,
                                      link.linkType,
                                      link.actionUri.toString(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          child: const Icon(
                              FluentIcons.more_horizontal_24_regular),
                        ),
                      ),
                    ),
                  ],
                ),
                text: publicUtilityBody.name,
              ),
            if (publicUtilityBodyAsync.isLoading)
              if (publicUtilityBody == null)
                const FluentCircularProgressIndicator()
              else
                const Positioned.fill(
                    child: Center(child: FluentCircularProgressIndicator())),
          ],
        ),
        if (publicUtilityBodyAsync.hasError)
          publicUtilityBodyAsync.hasValue
              ? ErrorComponent.discrete(
                  message:
                      errorResult?.error.toString() ?? "Erro ao carregar item",
                )
              : ErrorComponent(
                  message:
                      errorResult?.error.toString() ?? "Erro ao carregar item",
                ),
      ],
    );
  }
}
