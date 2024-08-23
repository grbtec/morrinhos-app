import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

extension FormBuilderUtils on GlobalKey<FormBuilderState> {
  /// clearErrors
  bool isUnchanged() {
    return currentState?.instantValue.entries
            .every((element) => element.value == null) ??
        false;
  }

  /// clearErrors
  void clearErrors() {
    for (var field in currentState!.fields.entries) {
      field.value.validate();
    }
  }

  /// setValidationErrors
  void setValidationErrors(Map<String, Object?> errors,
      void Function(List<String>) onGeneralErrors) {
    final fields = currentState!.fields;
    final List<String> nonFieldErrors = [];
    for (final error in errors.entries) {
      final field = fields[error.key];
      if (field != null) {
        field.invalidate((error.value! as List).join(" \n"));
      } else {
        nonFieldErrors.add("${error.key}: ${error.value.toString()}");
      }
    }
    if (nonFieldErrors.isNotEmpty) {
      onGeneralErrors(nonFieldErrors);
    }
  }
}
