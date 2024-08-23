import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/application_core/controllers/riverpod_paged_list_controller.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/repositories/public_utility_bodies_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final pagedPublicUtilityBodiesProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;

  // ignore: always_declare_return_types
  handle(bool useCache) => ref
      .read(publicUtilityBodiesRepositoryProvider)
      .getPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        search: search,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});

final publicUtilityBodyProvider =
    FutureProvider.family.autoDispose((ref, String id) {
  final useCache = ref.swr();
  return ref
      .read(publicUtilityBodiesRepositoryProvider)
      .getOne(id, useCache: useCache)
      .unwrapOrThrowResult();
});
