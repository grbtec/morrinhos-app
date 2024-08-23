import 'dart:async';

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
import 'package:mobile/components/overflow_max_height.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/model/employer.dart';
import 'package:mobile/model/post.dart';
import 'package:mobile/providers/employers_providers.dart';
import 'package:mobile/providers/jobs_providers.dart';
import 'package:mobile/providers/posts_providers.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/repositories/jobs_repository.dart';
import 'package:mobile/repositories/posts_repository.dart';
import 'package:mobile/services/launch_service.dart';
import 'package:mobile/services/share_service.dart';
import 'package:mobile/utils/riverpod_utils.dart';
import 'package:timeago/timeago.dart';

part 'pinned_list.dart';

part 'unpinned_list.dart';

part 'job_post_bottomsheet.dart';


part 'employers_paged_list.dart';

final _permissionsProvider = FutureProvider.autoDispose((ref) async {
  final permissionsFutures = [
    ref.read(employersRepositoryProvider).checkCreationPermission(),
    ref.read(jobsRepositoryProvider).checkCreationPermission(),
  ];
  final permissionsResults = await Future.wait(permissionsFutures);
  final permissionsList = permissionsResults
      .map((result) => result.asValue?.value == true)
      .toList();
  final permissions = (employers: permissionsList[0], jobs: permissionsList[1]);
  return permissions;
});

final _pagedPinnedEmployersProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber) = params;
  handle(bool useCache) => ref
      .read(employersRepositoryProvider)
      .getEmployersPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        pinned: true,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});


final _pinnedJobPostsProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;

  handle(bool useCache) => ref
      .read(postsRepositoryProvider)
      .getJobPostsPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        pinned: true,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});

class JobPostsView extends ConsumerStatefulWidget {
  final String? postId;

  const JobPostsView({super.key, this.postId});

  @override
  ConsumerState<JobPostsView> createState() => _JobPostsViewState();
}

class _JobPostsViewState extends ConsumerState<JobPostsView>
    with _JobPostBottomSheet {
  static const firstPageParams =
      PagedListQueryParams(pageNumber: 0, search: null);
  final searchRx = Rx<String?>(null);
  final selectedEmployerRx = Rx<String?>(null);
  late final scrollController = ScrollController();
  Size headerSize = Size.zero;

  @override
  void initState() {
    super.initState();
    searchRx.addListener(() {
      if (searchRx() == null) {
        if (scrollController.offset > 0) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        if (scrollController.offset < headerSize.height) {
          scrollController.animateTo(
            headerSize.height,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    final postId = widget.postId;
    if (postId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showJobPostBottomSheet(postId);
      });
    }
  }

  void onAddClick() async {
    final succeeded = await context.pushNamed(Routes.jobRegistryCreate);
    if (succeeded == true) {
      // Refresh providers
      const employersParams = PagedListQueryParams(pageNumber: 0, search: null);
      final _ = await ref
          .refresh(_pagedPinnedEmployersProvider(employersParams).future);
      // Wait for async post creation
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return;
      // Refresh providers
      final params = PagedListQueryParams(pageNumber: 0, search: searchRx());
      final __ = await ref.refresh(jobPostsProvider(params).future);
      final ___ = await ref.refresh(_pinnedJobPostsProvider(params).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_pinnedJobPostsProvider(firstPageParams));
    ref.watch(jobPostsProvider(firstPageParams));
    final permissionsAsync = ref.watch(_permissionsProvider);
    final permissions = permissionsAsync.valueOrNull;

    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavLeftTitle(
          title: "Vagas de Emprego",
        ),
        actions: [
          if (permissions != null && permissions.jobs == true)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(FluentIcons.add_24_regular),
              onPressed: onAddClick,
            ),
        ],
        child: FluentSearchBar.leftAligned(
          onSearch: (value) async {
            searchRx(value);
            final _ = await ref
                .refresh(jobPostsProvider(firstPageParams).future);
          },
          onCancelOperation: () {
            FocusScope.of(context).unfocus();
            searchRx.value = null;
          },
          onEmpty: () => searchRx.value = null,
          onClearOperation: () => searchRx.value = null,
        ),
      ),
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  headerSize = context.size ?? headerSize;
                });
                return Obx(
                  () => Column(
                    children: [
                      const FluentSectionHeader(
                        title: "Empresas Parceiras",
                      ),
                      FluentContainer(
                        padding: EdgeInsets.only(top: FluentSize.size120.value),
                        width: double.maxFinite,
                        child: SizedBox(
                          height: 92,
                          child: _EmployersPagedList(
                            selectedEmployerRx: selectedEmployerRx,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: FluentSize.size60.value,
                      ),
                      if (selectedEmployerRx() == null)
                        const FluentSectionHeader(
                          title: "Vagas em Destaques",
                          // actions: FluentSectionHeaderActions(
                          //   action1: const Icon(FluentIcons.grid_20_regular),
                          //   action2: const Icon(FluentIcons.list_20_regular),
                          // ),
                        ),
                      if (selectedEmployerRx() == null)
                        const SizedBox(
                          height: 200,
                          child: _PinnedList(),
                        ),
                    ],
                  ),
                );
              },
            ))
          ];
        },
        body: Column(
          children: [
            const FluentSectionHeader(
              title: "Vagas de emprego",
            ),
            Expanded(
              child: Obx(
                () => _UnpinnedList(
                  key: ValueKey([searchRx(), selectedEmployerRx()]),
                  search: searchRx(),
                  selectedEmployerId: selectedEmployerRx(),
                  pinned: selectedEmployerRx() == null?false:null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchRx.close();
    selectedEmployerRx.close();
    super.dispose();
  }
}
