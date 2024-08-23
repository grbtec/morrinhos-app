import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/components/error_component.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/model/post.dart';
import 'package:mobile/providers/posts_providers.dart';
import 'package:mobile/utils/riverpod_utils.dart';

class PostView extends ConsumerStatefulWidget {
  final String id;

  const PostView({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<PostView> createState() => _PostViewState();
}

class _PostViewState extends ConsumerState<PostView> {
  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    final post = await ref.read(postProvider(widget.id).future);
    if (!mounted) return;
    switch (post.relation?.referenceType) {
      case PostRelationReferenceType.jobVacancy:
        context.goNamed(
          Routes.jobPost,
          pathParameters: {"postId": widget.id},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postProvider(widget.id));
    return FluentScaffold(
        appBar: FluentNavBar(
          title: NavCenterTitle(title: 'Post'),
        ),
        body: Center(
          child: postAsync.hasError
              ? ErrorComponent(
                  message: "Erro ao carregar o post. "
                      "${postAsync.errorResult?.transform(
                            (result) => result.error,
                          ) ?? ""}",
                  onTryAgainClick: () {
                    final _ = ref.refresh(postProvider(widget.id));
                  },
                )
              : postAsync.isLoading
                  ? FluentText("Carregando...")
                  : FluentText(
                      "Não foi possível reconhecer o post. Atualize o APP."),
        ));
  }
}
