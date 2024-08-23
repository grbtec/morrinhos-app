import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_getx_observable/gbt_getx_observable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/application_core/controllers/riverpod_paged_list_controller.dart';
import 'package:mobile/components/my_paged_child_builder_delegate.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/model/post.dart';
import 'package:mobile/model/search_item.dart';
import 'package:mobile/repositories/posts_repository.dart';
import 'package:mobile/repositories/search_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final _pagedSearchItemsProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;

  return ref.read(searchRepositoryProvider).searchPaged(
    variants: [SearchItemVariant.post, SearchItemVariant.employer],
    search: search ?? "*",
    pageNumber: pageNumber,
    useCache: false,
  ).unwrapOrThrowResult();
});

final _postProvider = FutureProvider.family.autoDispose((ref, String id) {
  final useCache = ref.swr();
  return ref
      .read(postsRepositoryProvider)
      .getOne(id, useCache: useCache)
      .unwrapOrThrowResult();
});

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final searchRx = Rx<String?>(null);

  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavLeftTitle(
          title: "Buscar",
        ),
        child: FluentSearchBar.leftAligned(
          hintText: "Empregadores, vagas de emprego...",
          onSearch: (value) async {
            searchRx(value);
            final _ = await ref.refresh(_pagedSearchItemsProvider(
              PagedListQueryParams(pageNumber: 0, search: value),
            ).future);
          },
          onCancelOperation: () {
            FocusScope.of(context).unfocus();
            searchRx.value = null;
          },
          onEmpty: () => searchRx.value = null,
          onClearOperation: () => searchRx.value = null,
        ),
      ),
      body: Obx(
        () => (searchRx()?.length ?? 0) < 2
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.info_12_filled,
                      color: createColorMode(Theme.of(context).brightness)(
                        FluentColors.neutralBackground2Pressed,
                        FluentDarkColors.neutralBackground2Pressed,
                      ),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    FluentText(
                      "Digite pelo menos 2 caracteres para buscar",
                      style: FluentThemeDataModel.of(context)
                          .fluentTextTheme
                          ?.body1
                          ?.fluentCopyWith(
                            fluentColor:
                                createColorMode(Theme.of(context).brightness)(
                              FluentColors.neutralForeground2Rest,
                              FluentDarkColors.neutralForeground2Rest,
                            ),
                          ),
                    ),
                  ],
                ),
              )
            : _SearchPagedList(
                key: ValueKey(searchRx()),
                search: searchRx(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    searchRx.close();
    super.dispose();
  }
}

class _SearchPagedList extends ConsumerStatefulWidget {
  final String? search;

  const _SearchPagedList({
    super.key,
    this.search,
  });

  @override
  ConsumerState<_SearchPagedList> createState() => _SearchPagedListState();
}

class _SearchPagedListState extends ConsumerState<_SearchPagedList> {
  late final searchPagedListController = RiverpodPagedListController(
    this,
    _pagedSearchItemsProvider,
    search: widget.search,
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, SearchItem>.separated(
      separatorBuilder: (context, index) => const FluentStrokeDivider(
        startIndent: FluentStrokeBorderIndent.strokeIndent72,
      ),
      pagingController: searchPagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
          controller: searchPagedListController.pagingController,
          itemBuilder: (BuildContext context, item, int index) {
            return Consumer(builder: (context, ref, child) {
              AsyncValue<Post>? postAsync;
              if (item.variant == SearchItemVariant.post) {
                postAsync = ref.watch(_postProvider(item.id));
              }
              void onClick() async {
                final String nextRoute;
                switch (item.variant) {
                  case SearchItemVariant.post:
                    final future = ref.read(_postProvider(item.id).future);
                    final canceled = await FluentHeadsUpDisplayDialog(
                      future: future,
                      confirmStopMessage: "Cancelar?",
                      hud: const FluentHeadsUpDisplay(
                        text: "Carregando...",
                      ),
                    ).show(context);
                    if (canceled == true) return;
                    final post = await future;
                    switch (post.relation?.referenceType) {
                      case PostRelationReferenceType.jobVacancy:
                        nextRoute = Routes.jobPost;
                        break;
                      default:
                        FluentToast(
                          text: FluentText("Atualize o APP!"),
                        ).show(context: context);
                        return;
                    }
                    break;
                  case SearchItemVariant.employer:
                    nextRoute = Routes.employer;
                    break;
                  default:
                    FluentToast(
                      text: FluentText("Atualize o APP!"),
                    ).show(context: context);
                    return;
                }
                if (!context.mounted) return;
                await context
                    .pushNamed(nextRoute, pathParameters: {"id": item.id});
              }

              return FluentListItemMultiLine(
                leading: item.imageUrl?.transform((imageUrl) => FluentAvatar(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    )),
                text: item.title,
                subtext: item.subtitle,
                trailing: switch (item.variant) {
                  SearchItemVariant.post => switch (
                        postAsync?.valueOrNull?.relation?.referenceType) {
                      PostRelationReferenceType.jobVacancy => "Vaga",
                      _ => null,
                    },
                  SearchItemVariant.employer => "Empresa",
                  _ => null,
                }
                    ?.transform((text) => FluentChip.none(
                          text: text,
                          chipColor: FluentChipColor.brand,
                          chipColorsStyle: FluentChipColorStyle.tint,
                        )),
                onTap: onClick,
              );
            });
          }),
    );
  }
}
