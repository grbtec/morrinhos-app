import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/repositories/posts_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final postProvider = FutureProvider.family.autoDispose((ref, String id) {
  final repository = ref.read(postsRepositoryProvider);
  final useCache = ref.swr();
  return repository.getOne(id, useCache: useCache).unwrapOrThrowResult();
});

final postEngagementMetricsProvider = FutureProvider.family.autoDispose((ref, String id) {
  final repository = ref.read(postsRepositoryProvider);
  final useCache = ref.swr();
  return repository.getPostEgagementMetrics(id, useCache: useCache).unwrapOrThrowResult();
});
