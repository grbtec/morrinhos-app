import 'package:flutter/cupertino.dart';
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
import 'package:mobile/providers/jobs_providers.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/repositories/jobs_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final _pagedJobsProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;
  handle(bool useCache) => ref
      .read(jobsRepositoryProvider)
      .getJobsPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        search: search,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});


class JobListView extends ConsumerStatefulWidget {
  const JobListView({super.key});

  @override
  ConsumerState<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends ConsumerState<JobListView> {
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
            title: NavCenterTitle(title: "Lista de vaga de emprego"),
            actions: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(FluentIcons.add_24_regular),
                onPressed: () {
                  context.pushNamed(Routes.jobRegistryCreate).then(
                    (succeeded) async {
                      if (succeeded == true) {
                        final params = PagedListQueryParams(
                            pageNumber: 0, search: searchRx());
                        final _ = await ref
                            .refresh(_pagedJobsProvider(params).future);
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
                  hintText: "Vaga de emprego",
                  onSearch: (value) async {
                    searchRx(value);
                    final _ = await ref.refresh(_pagedJobsProvider(
                            PagedListQueryParams(pageNumber: 0, search: value))
                        .future);
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
                    () => _JobsPagedList(
                      key: ValueKey((searchRx(), updateRx())),
                      search: searchRx(),
                      update: () async {
                        final params = PagedListQueryParams(
                            pageNumber: 0, search: searchRx());
                        final _ = await ref
                            .refresh(_pagedJobsProvider(params).future);
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

class _JobsPagedList extends ConsumerStatefulWidget {
  final String? search;
  final VoidCallback update;

  const _JobsPagedList({
    super.key,
    this.search,
    required this.update,
  });

  @override
  ConsumerState<_JobsPagedList> createState() => _JobsPagedListState();
}

class _JobsPagedListState extends ConsumerState<_JobsPagedList> {
  late final jobPagedListController = RiverpodPagedListController(
    this,
    _pagedJobsProvider,
    search: widget.search,
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, IdHolder>(
      pagingController: jobPagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
        controller: jobPagedListController.pagingController,
          itemBuilder: (BuildContext context, item, int index) {
        return Consumer(builder: (context, ref, child) {
          final jobAsync = ref.watch(jobProvider(item.id));
          final job = jobAsync.valueOrNull;

          if (jobAsync.hasError) {
            return const ListTile(
              title: Text("Erro ao carregar vagas de emprego"),
              leading: Icon(FluentIcons.error_circle_24_regular),
            );
          }

          if (job == null) {
            return const ListTile(
              title: Text("Carregando..."),
              leading: CircularProgressIndicator(),
            );
          }

          void onClick() {
            context.pushNamed(Routes.jobRegistryUpdate, pathParameters: {
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
                job.coverImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            text: job.title,
            onTap: onClick,
          );
        });
      }),
    );
  }
}
