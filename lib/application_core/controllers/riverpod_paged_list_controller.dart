import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/application_core/controllers/view_controller.dart';

typedef _ProviderType<TValue>
= AutoDisposeFutureProviderFamily<PagedList<TValue>, PagedListQueryParams>;

class RiverpodPagedListController<TState extends ConsumerState, TValue>
    extends ViewController<TState> {
  final _ProviderType<TValue> provider;
  final pagingController = PagingController<int, TValue>(firstPageKey: 0);
  final String? search;
  final Map<String, String> extra;

  RiverpodPagedListController(super.state,
      this.provider, {
        this.search,
        this.extra = _emptyMap,
      }) {
    pagingController.addPageRequestListener(pageRequestListener);
  }

  void pageRequestListener(int pageNumber) async {
    final params = PagedListQueryParams(
        pageNumber: pageNumber, search: search, extra: extra);
    try {
      final page = await state.ref.read(provider(params).future);

      if (page.results.length < page.pageSize) {
        pagingController.appendLastPage(page.results);
      } else {
        pagingController.appendPage(page.results, pageNumber + 1);
      }
    } catch (exception) {
      state.ref.invalidate(provider(params));
      pagingController.error = exception is ErrorResult
          ? exception.error.toString()
          : "Erro desconhecido";
      if(kDebugMode && exception is! ErrorResult){
        unawaited(Future.microtask(()=>throw exception));
      }
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
  }
}

class PagedListQueryParams {
  final int pageNumber;
  final String? search;
  final Map<String, String> extra;

  const PagedListQueryParams({
    required this.pageNumber,
    required this.search,
    this.extra = _emptyMap,
  });

  @override
  bool operator ==(Object other) =>
      other is PagedListQueryParams &&
          other.pageNumber == pageNumber &&
          other.search == search &&
          other.extra.valueHashCode == extra.valueHashCode;

  @override
  int get hashCode =>
      Object.hash(
          pageNumber,
          search,
          extra.valueHashCode,
      );
}

const _emptyMap = <String, String>{};


extension _MapExtensions<T, U> on Map<T, U>{
  int get valueHashCode {
    return Object.hashAllUnordered(
      entries.map((e) => Object.hash(e.key, e.value)),
    );
  }
}