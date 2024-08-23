import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_getx_observable/gbt_getx_observable.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobile/application_core/controllers/riverpod_paged_list_controller.dart';
import 'package:mobile/components/cloudflare_image_uploader.dart';
import 'package:mobile/components/form_builder_fluent_text_field.dart';
import 'package:mobile/components/my_paged_child_builder_delegate.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/model/job_vacancy.dart';
import 'package:mobile/providers/employers_providers.dart';
import 'package:mobile/providers/jobs_providers.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/repositories/jobs_repository.dart';
import 'package:mobile/screen/(authenticated)/job_registry/job_registry_controller.dart';
import 'package:mobile/utils/riverpod_utils.dart';

final _pagedEmployersProvider =
    FutureProvider.family.autoDispose((ref, PagedListQueryParams params) {
  final PagedListQueryParams(:pageNumber, :search) = params;
  handle(bool useCache) => ref
      .read(employersRepositoryProvider)
      .getEmployersPaged(
        pageNumber: pageNumber,
        useCache: useCache,
        search: search,
      )
      .unwrapOrThrowResult();

  final useCache = ref.swr(onEagerlyDispose: () => handle(false));

  return handle(useCache);
});


class JobRegistryView extends ConsumerStatefulWidget {
  final String? id;

  const JobRegistryView({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<JobRegistryView> createState() => _JobRegistryViewState();
}

class _JobRegistryViewState extends ConsumerState<JobRegistryView> {
  late final controller = JobRegistryController(this);

  void resetForm(BuildContext context, JobVacancy jobVacancy) {
    controller.selectedEmployerRx(jobVacancy.employer.id);
    controller.coverImageUrlRx(jobVacancy.coverImageUrl);
    DefaultTabController.of(context).animateTo(1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.formKey.currentState!.patchValue({
        ...jobVacancy.toJson(),
        ...jobVacancy.additionalInfo,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final jobVacancyAsync = id == null ? null : ref.watch(jobProvider(id));

    return controller.provider(
      child: FormBuilder(
        key: controller.formKey,
        child: DefaultTabController(
          length: 2,
          child: Consumer(
            builder: (context, ref, child) {
              if (id != null) {
                final readyJobVacancy = ref.read(jobProvider(id)).valueOrNull;
                if (readyJobVacancy != null) {
                    resetForm(context,readyJobVacancy);
                } else {
                  ref.listen(jobProvider(id), (previous, next) async {
                    final jobVacancy = next.valueOrNull;
                    if (jobVacancy != null) {
                      resetForm(context,jobVacancy);
                    }
                  });
                }
              }
              return child ?? Container();
            },
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: FluentScaffold(
                appBar: FluentNavBar(
                  title: NavCenterTitle(
                    title: id != null
                        ? "Editar vaga de emprego"
                        : "Cadastrar vaga de emprego",
                  ),
                  actions: [
                    if (id != null)
                      IconButton(
                        icon: const Icon(FluentIcons.delete_24_regular),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Deletar vaga de emprego"),
                                content: const Text(
                                    "Tem certeza que deseja deletar essa vaga de emprego?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (await controller.onDeleteClick(id) &&
                                          context.mounted) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                    child: const Text("Deletar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
                body: Column(
                  children: [
                    if (jobVacancyAsync != null && jobVacancyAsync.isLoading)
                      const FluentProgressBar(value: null),
                    if (jobVacancyAsync != null && jobVacancyAsync.hasError)
                      ListTile(
                        title: const Text("Erro ao carregar vaga"),
                        subtitle: jobVacancyAsync.errorResult?.error
                            .transform((error) => Text("$error")),
                        leading:
                            const Icon(FluentIcons.error_circle_24_regular),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Expanded(
                              child: TabBarView(
                                children: [
                                  _Step1(),
                                  _Step2(),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Obx(
                                  () => FluentButton(
                                    title: id != null
                                        ? "Enviar atualizações"
                                        : "Cadastrar vaga de emprego",
                                    onPressed: controller.isFormLockedRx() ||
                                            controller.coverImageUrlRx() ==
                                                null ||
                                            jobVacancyAsync?.isLoading == true
                                        ? null
                                        : () {
                                            controller
                                                .onSubmitClick(id)
                                                .then((value) {
                                              if (value.isValue) {
                                                FluentToast(
                                                  title: FluentText("Sucesso"),
                                                  text: FluentText(
                                                    id == null
                                                        ? "Vaga cadastrada"
                                                        : "Vaga atualizada",
                                                  ),
                                                ).show(context: context);
                                                Navigator.of(context).pop(true);
                                              }
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step1 extends ConsumerStatefulWidget {
  const _Step1({super.key});

  @override
  ConsumerState<_Step1> createState() => _Step1State();
}

class _Step1State extends ConsumerState<_Step1> {
  final searchRx = Rx<String?>(null);
  final updateRx = Rx<bool>(false);

  void _onEmployerRegistryCreateClick() {
    context
        .pushNamed(Routes.employerRegistryCreate)
        .then((succeeded) async {
      if (succeeded == true) {
        if (!mounted) return;
        final params = PagedListQueryParams(pageNumber: 0, search: searchRx());
        final _ = await ref.refresh(_pagedEmployersProvider(params).future);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        updateRx(!updateRx());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        key: ValueKey(updateRx()),
        children: [
          FluentSearchBar.leftAligned(
            hintText: "Empregador",
            onSearch: (value) async {
              searchRx(value);
              final _ = await ref.refresh(_pagedEmployersProvider(
                      PagedListQueryParams(pageNumber: 0, search: value))
                  .future);
            },
            onCancelOperation: () {
              FocusScope.of(context).unfocus();
              searchRx.value = null;
            },
            onEmpty: () => searchRx.value = null,
            onClearOperation: () => searchRx.value = null,
          ),
          Expanded(
              child: Column(
            children: [
              FluentList.oneLine(listItems: [
                FluentListItemOneLine(
                  leading: Icon(FluentIcons.add_24_regular),
                  text: "Cadastrar empregador",
                  trailing: Icon(FluentIcons.chevron_right_24_regular),
                  onTap: _onEmployerRegistryCreateClick,
                ),
              ]),
              Expanded(
                child: Obx(
                  () => _EmployersPagedList(
                    key: ValueKey(searchRx()),
                    search: searchRx(),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchRx.close();
    updateRx.close();
    super.dispose();
  }
}

class _EmployersPagedList extends ConsumerStatefulWidget {
  final String? search;

  const _EmployersPagedList({
    super.key,
    this.search,
  });

  @override
  ConsumerState<_EmployersPagedList> createState() =>
      _EmployersPagedListState();
}

class _EmployersPagedListState extends ConsumerState<_EmployersPagedList> {
  late final employerPagedListController = RiverpodPagedListController(
    this,
    _pagedEmployersProvider,
    search: widget.search,
  );

  @override
  Widget build(BuildContext context) {
    final controller = JobRegistryController.of(context);
    return PagedListView<int, IdHolder>(
      pagingController: employerPagedListController.pagingController,
      builderDelegate: MyPagedChildBuilderDelegate(
          controller: employerPagedListController.pagingController,
          itemBuilder: (BuildContext context, item, int index) {
            return Consumer(builder: (context, ref, child) {
              final employerAsync = ref.watch(employerProvider(item.id));
              final employer = employerAsync.valueOrNull;

              if (employerAsync.hasError) {
                return const ListTile(
                  title: Text("Erro ao carregar empregador"),
                  leading: Icon(FluentIcons.error_circle_24_regular),
                );
              }

              if (employer == null) {
                return const ListTile(
                  title: Text("Carregando..."),
                  leading: CircularProgressIndicator(),
                );
              }

              void onClick() {
                controller.selectedEmployerRx(item.id);
                DefaultTabController.of(context).animateTo(1);
              }

              return Row(
                children: [
                  Obx(
                    () => FluentCheckbox(
                      value: controller.selectedEmployerRx() == item.id,
                      onChanged: (_) => onClick(),
                    ),
                  ),
                  Expanded(
                    child: FluentListItemOneLine(
                      leading: FluentAvatar(
                        child: Image.network(
                          employer.logoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      text: employer.name,
                      onTap: onClick,
                    ),
                  ),
                ],
              );
            });
          }),
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = JobRegistryController.of(context);
    return Obx(
      () => controller.selectedEmployerRx().transform(
            (employerId) => employerId == null
                ? const _Fallback("Selecione um empregador")
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final employerAsync =
                                ref.watch(employerProvider(employerId));
                            final employer = employerAsync.valueOrNull;
                            if (employer == null) {
                              return const CircularProgressIndicator();
                            }
                            return FluentListItemOneLine(
                              leading: FluentAvatar(
                                child: Image.network(
                                  employer.logoUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              text: employer.name,
                            );
                          },
                        ),
                        Obx(
                          () => CloudflareImageUploader(
                            key: ValueKey(controller.coverImageUrlRx()),
                            imageUrl: controller.coverImageUrlRx(),
                            onChange: (url) =>
                                controller.coverImageUrlRx.value = url,
                            text: "imagem de capa",
                          ),
                        ),
                        const FormBuilderFluentTextField(
                          name: "title",
                          label: "Título da vaga",
                        ),
                        const FormBuilderFluentTextField(
                          name: "comments",
                          label: "Comentários",
                          maxLines: 3,
                        ),
                        const FormBuilderFluentTextField(
                          name: "contactNumber",
                          label: "Número de contato",
                        ),
                        const FormBuilderFluentTextField(
                          name: "contactWhatsApp",
                          label: "WhatsApp de contato",
                        ),
                        const FormBuilderFluentTextField(
                          name: "contactUrl",
                          label: "Url de contato",
                        ),
                        const FormBuilderFluentTextField(
                          name: "contactEmail",
                          label: "Email de contato",
                        ),
                      ],
                    ),
                  ),
          ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String text;

  const _Fallback(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FluentText(text),
          FluentButton(
            variant: FluentButtonVariant.subtle,
            title: "Ok",
            onPressed: () {
              tabController.animateTo(tabController.index - 1);
            },
          )
        ],
      ),
    );
  }
}
