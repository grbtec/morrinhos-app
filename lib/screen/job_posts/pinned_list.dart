part of 'job_posts_view.dart';

class _PinnedList extends ConsumerStatefulWidget {
  const _PinnedList({super.key});

  @override
  ConsumerState<_PinnedList> createState() => _PinnedListState();
}

class _PinnedListState extends ConsumerState<_PinnedList> {
  late final pagedListController = RiverpodPagedListController(
    this,
    _pinnedJobPostsProvider,
    search: null,
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, IdHolder>.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 8, height: 8),
      scrollDirection: Axis.horizontal,
      pagingController: pagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
        controller: pagedListController.pagingController,
        itemBuilder: (BuildContext context, item, int index) {
          return Padding(
            padding:
                EdgeInsets.only(left: index == 0 ? 16 : 0, top: 1, bottom: 1),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: _PostCard(postId: item.id),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  final String postId;

  const _PostCard({super.key, required this.postId});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> with _JobPostBottomSheet {
  final popoverController = FluentPopoverController();
  final isHideRx = Rx(false);

  Widget _popoverOption({
    required Widget icon,
    required String text,
    required VoidCallback onClick,
  }) {
    return MaterialButton(
      onPressed: onClick,
      visualDensity: VisualDensity.compact,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8, height: 8),
          FluentText(text),
        ],
      ),
    );
  }

  void onUnhighlightClick() async {
    final post = await ref.read(postProvider(widget.postId).future);

    switch (post.relation?.referenceType) {
      case PostRelationReferenceType.jobVacancy:
        final postRelationId = post.relation?.id;
        if (postRelationId == null) {
          FluentToast(
            text: FluentText("Erro ao desdestacar vaga"),
          ).show(context: context);
          return;
        }
        final result =
            await ref.read(jobsRepositoryProvider).unpinJob(postRelationId);
        if (result.isValue) {
          popoverController.hide();
          isHideRx(true);
        }
        break;
      default:
        FluentToast(
          text: FluentText("Atualize o APP!"),
        ).show(context: context);
        return;
    }
  }

  void onEditClick() async {
    final post = await ref.read(postProvider(widget.postId).future);
    switch (post.relation?.referenceType) {
      case PostRelationReferenceType.jobVacancy:
        unawaited(context.pushNamed(Routes.jobRegistryUpdate, pathParameters: {
          "id": post.relation!.id,
        }).then((succeeded) {
          if (succeeded == true) {
            popoverController.hide();
            isHideRx(true);
          }
        }));
        break;
      default:
        FluentToast(
          text: FluentText("Atualize o APP!"),
        ).show(context: context);
        return;
    }
  }

  void onUnpublishClick() async {
    final post = await ref.read(postProvider(widget.postId).future);

    switch (post.relation?.referenceType) {
      case PostRelationReferenceType.jobVacancy:
        final postRelationId = post.relation?.id;
        if (postRelationId == null) {
          FluentToast(
            text: FluentText("Erro ao despublicar vaga"),
          ).show(context: context);
          return;
        }
        final result =
            await ref.read(jobsRepositoryProvider).unpublishJob(postRelationId);
        if (result.isValue) {
          popoverController.hide();
          isHideRx(true);
        }
        break;
      default:
        FluentToast(
          text: FluentText("Atualize o APP!"),
        ).show(context: context);
        return;
    }
  }

  void hide() {
    isHideRx(true);
  }

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(_permissionsProvider);
    final permissions = permissionsAsync.valueOrNull;
    final postAsync = ref.watch(postProvider(widget.postId));
    final post = postAsync.valueOrNull;
    if (postAsync.hasError && post == null) {
      return const SizedBox(
        width: 300,
        child: ListTile(
          title: Text("Erro ao carregar vaga"),
          leading: Icon(FluentIcons.error_circle_24_regular),
        ),
      );
    }
    return Obx(
      () => TweenAnimationBuilder(
        tween: Tween(
          begin: 1.0,
          end: isHideRx() ? 0.0 : 1.0,
        ),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          if (value == 0) {
            return const SizedBox.shrink();
          }
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (postAsync.isLoading && post == null)
              const Center(child: CircularProgressIndicator()),
            if (post != null)
              Stack(
                children: [
                  Positioned.fill(
                    child: FluentCard(
                      onPressed: () => _showJobPostBottomSheet(widget.postId),
                      coverImage: SizedBox(
                        width: double.maxFinite,
                        child: Image.network(
                          post.coverImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      text: post.title,
                      subText: post.subtitle,
                      leading: post.publisher?.transform(
                        (publisher) => FluentAvatar(
                          child: SizedBox(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            child: Image.network(
                              publisher.logoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (permissions != null && permissions.jobs)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: FluentCardContainer(
                        width: 28,
                        height: 28,
                        child: FluentPopover(
                          controller: popoverController,
                          axis: Axis.horizontal,
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FluentText(post.title),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _popoverOption(
                                  text: "Sem destaque",
                                  icon: const Icon(FluentIcons.pin_24_regular),
                                  onClick: onUnhighlightClick,
                                ),
                                _popoverOption(
                                  text: "Editar",
                                  icon: const Icon(FluentIcons.edit_24_regular),
                                  onClick: onEditClick,
                                ),
                                _popoverOption(
                                  text: "Despublicar",
                                  icon: const Icon(
                                      FluentIcons.slide_hide_24_regular),
                                  onClick: onUnpublishClick,
                                ),
                              ],
                            ),
                          ),
                          child: const Icon(
                              FluentIcons.more_horizontal_24_regular),
                        ),
                      ),
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    isHideRx.close();
    super.dispose();
  }
}
