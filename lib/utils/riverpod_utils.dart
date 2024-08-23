import 'dart:async';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RiverpodSwrUtils on AutoDisposeFutureProviderRef<Object?> {
  bool swr({VoidCallback? onEagerlyDispose}) {
    onDispose(() => onEagerlyDispose?.call());
    if (!state.hasValue) {
      listenSelf((previous, next) {
        if (previous is! AsyncError) {
          if (next is! AsyncLoading) {
            Future(() => invalidateSelf());
          }
        }
      });
    }
    return state.isLoading && !state.hasValue && !state.hasError;
  }
}

extension RiverpodErrorUtils<T> on AsyncValue<T> {
  ErrorResult? get errorResult {
    if (this is AsyncError<T>) {
      final error = this.error;
      if (error is ErrorResult) {
        return error;
      }
    }
    return null;
  }
}
