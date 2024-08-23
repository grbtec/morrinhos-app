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
import 'package:mobile/providers/employers_providers.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final _pagedEmployersProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;
  handle(bool useCache) => ref
      .read(employersRepositoryProvider)
      .getEmployersPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        search: search,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});


class EmployerListView extends ConsumerStatefulWidget {
  const EmployerListView({super.key});

  @override
  ConsumerState<EmployerListView> createState() => _EmployerListViewState();
}

class _EmployerListViewState extends ConsumerState<EmployerListView> {
  final searchRx = Rx<String?>(null);
  final updateRx = Rx<bool>(false);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: FluentScaffold(
          appBar: FluentNavBar(
            title: NavCenterTitle(title: "Lista de empregadores"),
            actions: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(FluentIcons.add_24_regular),
                onPressed: () {
                  context.pushNamed(Routes.employerRegistryCreate).then(
                    (succeeded) async {
                      if (succeeded == true) {
                        final params = PagedListQueryParams(
                            pageNumber: 0, search: searchRx());
                        final _ = await ref
                            .refresh(_pagedEmployersProvider(params).future);
                        await Future.delayed(const Duration(seconds: 2));
                        if (!mounted) return;
                        updateRx(!updateRx());
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                FluentSearchBar.leftAligned(
                  hintText: "Empregador",
                  onSearch: (value) async {
                    searchRx(value);
                    final _ = await ref.refresh(_pagedEmployersProvider(
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
                Expanded(
                  child: Obx(
                    () => _EmployersPagedList(
                      key: ValueKey((searchRx(), updateRx())),
                      search: searchRx(),
                      update: () async {
                        final params = PagedListQueryParams(
                            pageNumber: 0, search: searchRx());
                        final _ = await ref
                            .refresh(_pagedEmployersProvider(params).future);
                        await Future.delayed(const Duration(seconds: 2));
                        if (!mounted) return;
                        updateRx(!updateRx());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchRx.close();
    updateRx.close();
    super.dispose();
  }
}

class _EmployersPagedList extends ConsumerStatefulWidget {
  final String? search;
  final VoidCallback update;

  const _EmployersPagedList({
    super.key,
    this.search,
    required this.update,
  });

  @override
  ConsumerState<_EmployersPagedList> createState() =>
      _EmployersPagedListState();
}

class _EmployersPagedListState extends ConsumerState<_EmployersPagedList> {
  late final employerPagedListController = RiverpodPagedListController(
    this,
    _pagedEmployersProvider,
    search: widget.search,
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, IdHolder>(
      pagingController: employerPagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
          controller: employerPagedListController.pagingController,
          itemBuilder: (BuildContext context, item, int index) {
            return Consumer(builder: (context, ref, child) {
              final employerAsync = ref.watch(employerProvider(item.id));
              final employer = employerAsync.valueOrNull;

              if (employerAsync.hasError) {
                return const ListTile(
                  title: Text("Erro ao carregar empregador"),
                  leading: Icon(FluentIcons.error_circle_24_regular),
                );
              }

              if (employer == null) {
                return const ListTile(
                  title: Text("Carregando..."),
                  leading: CircularProgressIndicator(),
                );
              }

              void onClick() {
                context.pushNamed(Routes.employerRegistryUpdate, pathParameters: {
                  "id": item.id,
                }).then((succeeded) async {
                  if (succeeded == true) {
                    widget.update();
                  }
                });
              }

              return FluentListItemOneLine(
                leading: FluentAvatar(
                  child: Image.network(
                    employer.logoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                text: employer.name,
                onTap: onClick,
              );
            });
          }),
    );
  }
}
