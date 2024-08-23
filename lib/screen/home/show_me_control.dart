import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/infrastructure/auth/auth_service.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';
import 'package:mobile/infrastructure/routes.dart';
import 'package:mobile/repositories/employers_repository.dart';
import 'package:mobile/repositories/jobs_repository.dart';

void showMeControl(ConsumerState state) {
  showFluentBottomSheet(
    context: state.context,
    half: true,
    child: _Content(),
  );
}

final hasEmployerPermissionProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(employersRepositoryProvider);
  final result = await repository.checkCreationPermission();
  return result.asValue?.value ?? false;
});
final hasJobsPermissionProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(jobsRepositoryProvider);
  final result = await repository.checkCreationPermission();
  return result.asValue?.value ?? false;
});

class _Content extends ConsumerStatefulWidget {
  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content> {
  Future<void> _onSignOutClick() async {
    final result = await ref.read(userCredentialProvider.notifier).signOut();
    final context = this.context;
    if (result.isError) {
      if (context.mounted) {
        FluentToast(
          title: FluentText("Erro ao sair. Tente novamente."),
          text: FluentText(result.asError!.error.toString()),
          toastColor: FluentToastColor.danger,
        ).show(context: context);
      }
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void onClaimsClick() {
    final futureClaimsResult = Future(
      () async {
        return ref.read(authServiceProvider).claims(
              await ref
                  .read(userCredentialProvider)
                  .value!
                  .getValidUserTokens(),
            );
      },
    );
    FluentHeadsUpDisplayDialog(
      future: futureClaimsResult,
      confirmStopMessage: 'Deseja cancelar?',
      hud: const FluentHeadsUpDisplay(
        text: "Carregando...",
      ),
    ).show(context).whenComplete(() {
      futureClaimsResult.then((result) {
        final claims = result.asValue!.value;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Claims'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var claim in claims)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FluentContainer(
                          padding: const EdgeInsets.all(8),
                          strokeStyle: FluentStrokeStyle(
                              thickness: FluentStrokeThickness.strokeWidth10,
                              dashArray: [5, 5]),
                          child: Text((claim as Map<String, Object?>?)
                                  ?.values
                                  .join(": ") ??
                              ""),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'),
                )
              ],
            );
          },
        );
      });
    });
  }

  void _onEmployersClick() {
    context.pushNamed(Routes.employerList);
  }

  void _onJobsClick() {
    context.pushNamed(Routes.jobList);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userCredentialProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8),
          height: 52,
          alignment: Alignment.bottomRight,
          child: FluentButton(
            variant: FluentButtonVariant.subtle,
            title: 'Sair',
            onPressed: _onSignOutClick,
          ),
        ),
        FluentListItemMultiLine(
          leading: const FluentAvatar(
            child: Icon(FluentIcons.person_24_regular),
          ),
          text: userAsync.value?.user.fullName,
          subtext: userAsync.value?.user.email,
          trailing: FluentButton(
            size: FluentButtonSize.small,
            variant: FluentButtonVariant.outline,
            title: "Claims",
            onPressed: onClaimsClick,
          ),
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final hasEmployerPermission =
                ref.watch(hasEmployerPermissionProvider);
            if (hasEmployerPermission.valueOrNull != true) {
              return const SizedBox.shrink();
            }
            return child ?? Container();
          },
          child: FluentListItemMultiLine(
            text: "Empregadores",
            subtext: "Cadastrar e editar empregadores",
            trailing: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _onEmployersClick,
              tooltip: "Cadastrar e editar vaga de emprego",
              icon: const Icon(FluentIcons.chevron_right_24_regular),
            ),
          ),
        ),
        Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final hasEmployerPermission =
                  ref.watch(hasJobsPermissionProvider);
              if (hasEmployerPermission.valueOrNull != true) {
                return SizedBox.shrink();
              }
              return child ?? Container();
            },
            child: FluentListItemMultiLine(
              text: "Vagas de emprego",
              subtext: "Cadastrar e editar vagas de emprego",
              trailing: IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _onJobsClick,
                tooltip: "Cadastrar e editar vaga de emprego",
                icon: const Icon(FluentIcons.chevron_right_24_regular),
              ),
            )),
      ],
    );
  }
}
