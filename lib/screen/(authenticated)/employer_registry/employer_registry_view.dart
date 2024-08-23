import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_dart_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_getx_observable/gbt_getx_observable.dart';
import 'package:mobile/components/cloudflare_image_uploader.dart';
import 'package:mobile/components/form_builder_fluent_text_field.dart';
import 'package:mobile/utils/result_extension.dart';
import 'package:mobile/providers/employers_providers.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/screen/(authenticated)/employer_registry/employer_registry_controller.dart';
import 'package:mobile/utils/riverpod_utils.dart';

class EmployerRegistryView extends ConsumerStatefulWidget {
  final String? id;

  const EmployerRegistryView({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<EmployerRegistryView> createState() =>
      _EmployerRegistryViewState();
}

class _EmployerRegistryViewState extends ConsumerState<EmployerRegistryView> {
  late final controller = EmployerRegistryController(this);

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final employerAsync = id == null ? null : ref.watch(employerProvider(id));
    if (id != null) {
      ref.listen(employerProvider(id), (previous, next) async {
        final employer = next.valueOrNull;
        if (employer != null) {
          controller.logoUrlRx(employer.logoUrl);
          controller.formKey.currentState!.patchValue({
            ...employer.toJson(),
          });
        }
      });
    }
    return FormBuilder(
      key: controller.formKey,
      child: DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FluentScaffold(
            appBar: FluentNavBar(
              title: NavCenterTitle(
                title:
                    id != null ? "Editar empregador" : "Cadastrar empregador",
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
                            title: const Text("Deletar empregador"),
                            content: const Text(
                                "Tem certeza que deseja deletar esse empregador?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
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
                if (employerAsync != null && employerAsync.isLoading)
                  const FluentProgressBar(value: null),
                if (employerAsync != null && employerAsync.hasError)
                  ListTile(
                    title: const Text("Erro ao carregar empregador"),
                    subtitle: employerAsync.errorResult?.error
                        .transform((error) => Text("$error")),
                    leading: const Icon(FluentIcons.error_circle_24_regular),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Obx(
                                  () => CloudflareImageUploader(
                                    key: ValueKey(controller.logoUrlRx()),
                                    imageUrl: controller.logoUrlRx(),
                                    onChange: (url) =>
                                        controller.logoUrlRx.value = url,
                                    text: "imagem de perfil",
                                  ),
                                ),
                                const FormBuilderFluentTextField(
                                  name: "name",
                                  label: "Nome",
                                ),
                              ],
                            ),
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
                                    : "Cadastrar empregador",
                                onPressed: controller.isFormLockedRx() ||
                                        controller.logoUrlRx() == null ||
                                        employerAsync?.isLoading == true
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
                                                    ? "Empregador cadastrado"
                                                    : "Empregador atualizado",
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
    );
  }
}
