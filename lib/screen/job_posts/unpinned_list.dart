part of 'job_posts_view.dart';

class _UnpinnedList extends ConsumerStatefulWidget {
  final String? search;
  final String? selectedEmployerId;
  final bool? pinned;

  const _UnpinnedList({
    super.key,
    required this.search,
    required this.selectedEmployerId,
    required this.pinned,
  });

  @override
  ConsumerState<_UnpinnedList> createState() => _UnpinnedListState();
}

class _UnpinnedListState extends ConsumerState<_UnpinnedList> {
  late final pagedListController = RiverpodPagedListController(
    this,
    jobPostsProvider,
    search: widget.search,
    extra: {
      if (widget.selectedEmployerId != null)
        "employerId": widget.selectedEmployerId!,
      if (widget.pinned != null)
        "pinned": widget.pinned!.toString(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, IdHolder>.separated(
      separatorBuilder: (context, index) => const FluentStrokeDivider(
        startIndent: FluentStrokeBorderIndent.strokeIndent72,
      ),
      pagingController: pagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
        controller: pagedListController.pagingController,
        itemBuilder: (BuildContext context, item, int index) {
          return _PostTile(postId: item.id);
        },
      ),
    );
  }
}

class _PostTile extends ConsumerStatefulWidget {
  final String postId;

  _PostTile({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<_PostTile> createState() => _PostTileState();
}

class _PostTileState extends ConsumerState<_PostTile> with _JobPostBottomSheet {
  final popoverController = FluentPopoverController();
  final isHideRx = Rx(false);

  void onClick() async {
    unawaited(_showJobPostBottomSheet(widget.postId));
    final result = await ref
        .read(postsRepositoryProvider)
        .incrementPostViewCount(widget.postId);
    if (result.isValue) {
      await Future.delayed(const Duration(seconds: 2));
      ref.refresh(postEngagementMetricsProvider(widget.postId));
    }
  }

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

  void onHighlightClick() async {
    final post = await ref.read(postProvider(widget.postId).future);

    switch (post.relation?.referenceType) {
      case PostRelationReferenceType.jobVacancy:
        final postRelationId = post.relation?.id;
        if (postRelationId == null) {
          FluentToast(
            text: FluentText("Erro ao destacar vaga"),
          ).show(context: context);
          return;
        }
        final result =
            await ref.read(jobsRepositoryProvider).pinJob(postRelationId);
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
        final succeeded =
            await context.pushNamed(Routes.jobRegistryUpdate, pathParameters: {
          "id": post.relation!.id,
        });
        if (succeeded == true) {
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
              Builder(
                builder: (context) {
                  final postEngagementMetricsAsync =
                      ref.watch(postEngagementMetricsProvider(widget.postId));
                  final postEngagementMetrics =
                      postEngagementMetricsAsync.valueOrNull;
                  final postRelationJobId = post.relation?.referenceType ==
                          PostRelationReferenceType.jobVacancy
                      ? post.relation!.id
                      : null;
                  final jobVacancyAsync = postRelationJobId == null
                      ? null
                      : ref.watch(jobProvider(postRelationJobId));
                  final jobVacancy = jobVacancyAsync?.valueOrNull;
                  final employerAsync = jobVacancy == null
                      ? null
                      : ref.watch(employerProvider(jobVacancy.employer.id));
                  final employer = employerAsync?.valueOrNull;
                  return FluentListItemMultiLine(
                    onTap: onClick,
                    leading: Image.network(
                      post.coverImageUrl,
                      fit: BoxFit.cover,
                    ),
                    text: post.title,
                    subtext: ""
                        "${employer?.name ?? ""} • "
                        "${format(post.creationDateTime, locale: "pt_BR")} • "
                        "${postEngagementMetrics?.viewCount ?? ""} clicks",
                    trailing: permissions != null && permissions.jobs
                        ? FluentPopover(
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
                                    text: "Destacar",
                                    icon:
                                        const Icon(FluentIcons.pin_24_regular),
                                    onClick: onHighlightClick,
                                  ),
                                  _popoverOption(
                                    text: "Editar",
                                    icon:
                                        const Icon(FluentIcons.edit_24_regular),
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
                          )
                        : null,
                  );
                },
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
