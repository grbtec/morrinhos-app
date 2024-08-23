
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_getx_observable/extensions.dart';
import 'package:gbt_getx_observable/gbt_getx_observable.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';
import 'package:mobile/utils/form_builder_utils.dart';

import '../../components/form_builder_fluent_text_field.dart';

void showLoginBottomSheet(ConsumerState state) {
  final isFormLockedRx = false.obs;
  final formKey = GlobalKey<FormBuilderState>();

  void submit() async {
    if (formKey.isUnchanged()) {
      FluentToast(
        text: FluentText("Preencha os dados de login."),
        toastColor: FluentToastColor.warning,
      ).show(context: state.context);
      return;
    }
    formKey.clearErrors();
    isFormLockedRx(true);
    try {
      final form = formKey.currentState!.instantValue;
      final signInResult = await state.ref.read(userCredentialProvider.notifier).signIn(
            form["username"] as String? ??"",
            form["password"] as String? ??"",
          );
      if (signInResult.isError) {
        final error = signInResult.asError!.error;
        final context = state.context;
        if (error is ValidationErrors) {
          formKey.setValidationErrors(error.errors, (errors) {
            for (var error in errors) {
              final index = errors.indexOf(error);
              if (context.mounted) {
                FluentToast(
                  title: FluentText("Erro"),
                  text: FluentText(error),
                  toastColor: FluentToastColor.danger,
                ).show(
                  context: state.context,
                  duration: Duration(seconds: 5 + errors.length - index - 1),
                  yOffset: -64 * (index + 1),
                );
              }
            }
          });
          return;
        }
        if (context.mounted) {
          FluentToast(
            title: FluentText("Erro"),
            text: FluentText(error.toString()),
            toastColor: FluentToastColor.danger,
          ).show(
            context: context,
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }
      if(signInResult.isValue){
        final context =state.context;
        if(context.mounted){
          Navigator.of(context).pop();
          FluentToast(
            title: FluentText("Sucesso"),
            text: FluentText("Login efetuado com sucesso"),
          ).show(context: context);
        }
      }
    } finally {
      isFormLockedRx(false);
    }
  }

  showFluentBottomSheet(
    context: state.context,
    headerTitle: FluentText("Informe as credenciais de acesso"),
    half: true,
    child: FormBuilder(
      key: formKey,
      child: LoginBottomSheetChild(),
    ),
    overlayBuilder: (int, size) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.maxFinite,
            child: Obx(
              () => FluentButton(
                title: "Fazer login",
                onPressed: isFormLockedRx() ? null : submit,
              ),
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {
    isFormLockedRx.close();
  });
}

class LoginBottomSheetChild extends StatefulWidget {
  const LoginBottomSheetChild({super.key});

  @override
  State<LoginBottomSheetChild> createState() => _LoginBottomSheetChildState();
}

class _LoginBottomSheetChildState extends State<LoginBottomSheetChild> {
  final FluentTextFieldController usernameController =
      FluentTextFieldController();
  final FluentTextFieldController passwordController =
      FluentTextFieldController();

  @override
  void initState() {
    super.initState();
  }

  void onTapTextField(
      String title, bool obscureText, FluentTextFieldController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FluentTextField(
            autofocus: true,
            controller: controller,
            label: title,
            obscureText: obscureText,
          ),
        );
      },
    );
  }

  void onSignInPressed() {
    print("Sign in pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FluentSectionDescription(
          description: "*Este login é dedicado somente a pessoas autorizadas",
        ),
        GestureDetector(
          onTap: () => onTapTextField("Usuário", false, usernameController),
          child: AbsorbPointer(
            child: IgnorePointer(
              child: FormBuilderFluentTextField(
                controller: usernameController,
                name: "username",
                label: "Usuário",
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onTapTextField("senha", true, passwordController),
          child: AbsorbPointer(
            child: IgnorePointer(
              child: FormBuilderFluentTextField(
                controller: passwordController,
                name: "password",
                label: "Senha",
                obscureText: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
