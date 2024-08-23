import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/components/error_component.dart';

class MyPagedChildBuilderDelegate<ItemType>
    extends PagedChildBuilderDelegate<ItemType> {
  final PagingController<int, ItemType> controller;

  MyPagedChildBuilderDelegate({
    required this.controller,
    required super.itemBuilder,
    super.animateTransitions = false,
    super.transitionDuration = const Duration(milliseconds: 250),
  }) : super(
          noItemsFoundIndicatorBuilder: (context) =>
              const ErrorComponent(message: "Nenhum resultado encontrado"),
          noMoreItemsIndicatorBuilder: (context) => LayoutBuilder(
            builder: (context, constraints) {
              // if(constraints.hasBoundedWidth){
              //   return const FluentStrokeDivider();
              // }
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.hasBoundedWidth
                      ? 0
                      : 8,
                  vertical: constraints.hasBoundedHeight
                      ? 0
                      : 8,
                ),
                child: FluentContainer(
                  strokeStyle: FluentStrokeStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    thickness: FluentStrokeThickness.strokeWidth20,
                    dashArray: [3, 3],
                    padding:1
                  ),
                ),
              );
            },
          ),
          firstPageErrorIndicatorBuilder: (context) => ErrorComponent(
            message: "Erro ao carregar a lista",
            onTryAgainClick: () => controller.retryLastFailedRequest(),
          ),
          newPageErrorIndicatorBuilder: (context) => ErrorComponent(
            message: "Erro ao carregar a próxima página",
            onTryAgainClick: () => controller.retryLastFailedRequest(),
          ),
        );
}
