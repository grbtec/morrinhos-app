part of 'job_posts_view.dart';

mixin _JobPostBottomSheet<_ extends ConsumerStatefulWidget>
    on ConsumerState<_> {
  Future<void> _showJobPostBottomSheet(String id) async {
    final postAsync = ref.read(postProvider(id));
    final Post post =
        postAsync.valueOrNull ?? await ref.read(postProvider(id).future);
    if (!mounted) return;
    await showFluentBottomSheet(
      context: context,
      headerLeading: GestureDetector(
        child: const Row(
          children: [
            Icon(FluentIcons.chevron_left_24_filled),
            Text("Voltar"),
          ],
        ),
        onTap: () => Navigator.of(context).pop(),
      ),
      headerTitle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 120),
        child: FluentText(
          post.title,
          textOverflow: TextOverflow.ellipsis,
        ),
      ),
      headerTrailing: Consumer(
        builder: (_, ref, __) {
          return GestureDetector(
            child: const Text("Compartilhar"),
            onTap: () {
              ref.read(shareServiceProvider).shareResource(
                    post.title,
                    ResourceType.post,
                    id,
                  );
            },
          );
        },
      ),
      overlayBuilder: (_, __) {
        return Positioned.fill(
          child: OverflowMaxHeight(
            heightDifference: 7.7,
            child: _JobPostBottomSheetContent(
              post: post,
            ),
          ),
        );
      },
      child: Container(),
    );
  }
}

class _JobPostBottomSheetContent extends StatelessWidget {
  final Post post;

  const _JobPostBottomSheetContent({
    super.key,
    required this.post,
  });

  void launch(LaunchType type, String value) {
    LaunchService().launch(type, value);
  }

  @override
  Widget build(BuildContext context) {
    final postRelationJobId =
        post.relation?.referenceType == PostRelationReferenceType.jobVacancy
            ? post.relation!.id
            : null;
    return Consumer(
      builder: (context, ref, _) {
        final jobVacancyRevisionAsync = postRelationJobId == null
            ? null
            : ref.watch(jobRevisionProvider(
                (id: postRelationJobId, revision: post.relation!.revision),
              ));
        if (postRelationJobId != null) {
          ref.listen(
              jobRevisionProvider(
                (id: postRelationJobId, revision: post.relation!.revision),
              ), (previous, next) {
            if (next.hasError && !next.hasValue) {
              final errorResult = next.errorResult;
              FluentToast(
                title: errorResult == null
                    ? null
                    : FluentText("Erro ao carregar vaga"),
                text: errorResult?.error
                        .transform((error) => FluentText("$error")) ??
                    FluentText("Erro ao carregar vaga"),
                toastColor: FluentToastColor.danger,
              ).show(context: context);
            }
          });
        }
        final jobVacancyRevision = jobVacancyRevisionAsync?.valueOrNull;
        final contactNumber = jobVacancyRevision?.additionalInfo["contactNumber"];
        final contactWhatsapp = jobVacancyRevision?.additionalInfo["contactWhatsApp"];
        final contactEmail = jobVacancyRevision?.additionalInfo["contactEmail"];
        final contactUrl = jobVacancyRevision?.additionalInfo["contactUrl"];
        var buttonVariantConsumed = false;
        FluentButtonVariant getButtonVariant() {
          final variant = buttonVariantConsumed
              ? FluentButtonVariant.subtle
              : FluentButtonVariant.accent;
          buttonVariantConsumed = true;
          return variant;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20 + 52),
          child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                const FluentStrokeDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: IgnorePointer(
                            child: Column(
                              children: [
                                Expanded(
                                    child: Image.network(post.coverImageUrl)),
                                const SizedBox(height: 16),
                                FluentText(
                                  post.title,
                                  style: FluentThemeDataModel.of(context)
                                      .fluentTextTheme
                                      ?.title3,
                                ),
                                FluentText(
                                  post.subtitle,
                                  style: FluentThemeDataModel.of(context)
                                      .fluentTextTheme
                                      ?.caption1,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        if (contactWhatsapp != null) ...[
                          const SizedBox(height: 8),
                          FluentButton(
                            variant: getButtonVariant(),
                            title: "Contato por Whatsapp",
                            size: FluentButtonSize.large,
                            onPressed: () => launch(
                              LaunchType.whatsApp,
                              contactWhatsapp,
                            ),
                          ),
                        ],
                        if (contactNumber != null) ...[
                          const SizedBox(height: 8),
                          FluentButton(
                            variant: getButtonVariant(),
                            title: "Contato por Número",
                            size: FluentButtonSize.large,
                            onPressed: () => launch(
                              LaunchType.call,
                              contactNumber,
                            ),
                          ),
                        ],
                        if (contactEmail != null) ...[
                          const SizedBox(height: 8),
                          FluentButton(
                            variant: getButtonVariant(),
                            title: "Contato por Email",
                            size: FluentButtonSize.large,
                            onPressed: () => launch(
                              LaunchType.email,
                              contactEmail,
                            ),
                          ),
                        ],
                        if (contactUrl != null) ...[
                          const SizedBox(height: 8),
                          FluentButton(
                            variant: getButtonVariant(),
                            title: "Website",
                            size: FluentButtonSize.large,
                            onPressed: () => launch(
                              LaunchType.url,
                              contactUrl,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
