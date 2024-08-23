import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_essentials/gbt_dart_essentials.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:gbt_getx_observable/extensions.dart';
import 'package:gbt_getx_observable/gbt_getx_observable.dart';
import 'package:mobile/application_core/controllers/view_controller.dart';
import 'package:mobile/repositories/jobs_repository.dart';

class JobRegistryController extends ViewController<ConsumerState> {
  final formKey = GlobalKey<FormBuilderState>();
  final isFormLockedRx = false.obs;

  final selectedEmployerRx = Rx<String?>(null);
  final coverImageUrlRx = Rx<String?>(null);

  JobsRepository get jobsRepository => state.ref.read(jobsRepositoryProvider);

  JobRegistryController(super.state);

  Future<Result<void>> onSubmitClick(String? id) async {
    // Clear errors
    for (var field in formKey.currentState!.fields.entries) {
      field.value.validate();
    }
    isFormLockedRx(true);
    try {
      final requestBody = {
        "employer": {"id": selectedEmployerRx()},
        "coverImageUrl": coverImageUrlRx(),
        ...formKey.currentState!.instantValue,
      };
      final result = id == null
          ? await jobsRepository.create(requestBody)
          : await jobsRepository.update(id, requestBody);
      if (result is ErrorResult) {
        final resultError = result.error;
        if (resultError is ValidationErrors) {
          _setValidationErrors(resultError.errors);
        } else {
          if (state.mounted) {
            FluentToast(
              text: FluentText(resultError.toString()),
            ).show(context: state.context);
          }
        }
      }
      return result;
    } finally {
      isFormLockedRx(false);
    }
  }

  void _setValidationErrors(Map<String, Object?> errors) {
    final fields = formKey.currentState!.fields;
    List<String> nonFieldErrors = [];
    for (var error in errors.entries) {
      final field = fields[error.key];
      if (field != null) {
        field.invalidate((error.value as List).join(" \n"));
      } else {
        nonFieldErrors.add("${error.key}: ${error.value.toString()}");
      }
    }
    if (nonFieldErrors.length > 0) {
      _showError(nonFieldErrors.toString());
    }
  }

  void _showError(String errorMessage) {
    FluentToast(
      title: FluentText("Erro"),
      text: FluentText(errorMessage),
      toastColor: FluentToastColor.danger,
    ).show(context: state.context, duration: const Duration(seconds: 5));
  }

  Future<bool> onDeleteClick(String id) async {
    final future = state.ref.read(jobsRepositoryProvider).delete(id);
    await FluentHeadsUpDisplayDialog.showDialog(
      context: state.context,
      future: future,
      confirmStopMessage: "Cancelar?",
      hud: const FluentHeadsUpDisplay(
        text: "Apagando...",
      ),
    );
    final result = await future;
    if (result.isValue) {
      if (!state.mounted) return true;
      FluentToast(
        title: FluentText("Sucesso"),
        text: FluentText("Vaga deletada"),
      ).show(context: state.context);
      return true;
    } else {
      if (!state.mounted) return false;
      FluentToast(
        title: FluentText("Erro ao deletar vaga"),
        text: FluentText("${result.asError?.error}"),
      ).show(context: state.context);
      return false;
    }
  }

  @override
  void dispose() {
    isFormLockedRx.close();
    selectedEmployerRx.close();
    coverImageUrlRx.close();
  }

  Widget provider({required Widget child}) {
    return _Provider(this, child: child);
  }

  static JobRegistryController of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_Provider>()
            ?.controller ??
        (throw "No JobRegistryController found");
  }
}

class _Provider extends InheritedWidget {
  final JobRegistryController controller;

  _Provider(this.controller, {required super.child});

  @override
  bool updateShouldNotify(_Provider oldWidget) => true;
}
