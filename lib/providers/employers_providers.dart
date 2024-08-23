
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final employerProvider = FutureProvider.family.autoDispose((ref, String id) {
  final useCache = ref.swr();
  return ref
      .read(employersRepositoryProvider)
      .getEmployer(id, useCache: useCache)
      .unwrapOrThrowResult();
});