import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/application_core/controllers/riverpod_paged_list_controller.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/repositories/jobs_repository.dart';
import 'package:mobile/repositories/posts_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final jobPostsProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search, :extra) = params;

  final employerId = extra["employerId"];
  final pinned = extra["pinned"] == null ? null : extra["pinned"] == "true";
  handle(bool useCache) => ref
      .read(postsRepositoryProvider)
      .getJobPostsPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        pinned: pinned,
        search: search,
        employerId: employerId,
      )
      .unwrapOrThrowResult();
  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});

final jobProvider = FutureProvider.family.autoDispose((ref, String id) {
  final useCache = ref.swr();
  return ref
      .read(jobsRepositoryProvider)
      .getJob(id, useCache: useCache)
      .unwrapOrThrowResult();
});

final jobRevisionProvider = FutureProvider.family
    .autoDispose((ref, ({String id, DateTime revision}) params) {
  final useCache = ref.swr();
  return ref
      .read(jobsRepositoryProvider)
      .getJob(
        params.id,
        revision: params.revision,
        useCache: useCache,
      )
      .unwrapOrThrowResult();
});
