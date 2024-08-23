import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:mobile/components/controllable_fluent_text_field.dart';

class FormBuilderFluentTextField extends StatefulWidget {
  final String name;
  final FluentTextFieldController? controller;
  final String? hintText;
  final String? label;
  final String? assistiveText;
  final Icon? suffixIcon;
  final void Function(String value)? onChanged;
  final bool readOnly;
  final bool obscureText;
  final int maxLines;

  const FormBuilderFluentTextField({
    super.key,
    required this.name,
    this.controller,
    this.hintText,
    this.assistiveText,
    this.label,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  State<FormBuilderFluentTextField> createState() =>
      _FormBuilderFluentTextFieldState();
}

class _FormBuilderFluentTextFieldState
    extends State<FormBuilderFluentTextField> {
  late final FluentTextFieldController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? _InternalFluentTextFieldController();
    controller.textEditingController.addListener(onChanged);
  }

  void onChanged() {
    widget.onChanged?.call(controller.textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      name: widget.name,
      onChanged: (value) {
        widget.onChanged?.call(value ?? "");
      },
      builder: (field) {
        return ControllableFluentTextField.fluentTextField(
          value: field.value,
          onChanged: (text) => text.trim().isEmpty
              ? field.didChange(null)
              : field.didChange(text),
          controller: widget.controller,
          error: field.errorText,
          hintText: widget.hintText,
          assistiveText: widget.assistiveText,
          label: widget.label,
          suffixIcon: widget.suffixIcon,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
        );
      },
    );
  }

  @override
  void dispose() {
    if (controller is _InternalFluentTextFieldController) {
      controller.dispose();
    } else {
      controller.textEditingController.removeListener(onChanged);
    }
    super.dispose();
  }
}

class _InternalFluentTextFieldController extends FluentTextFieldController {}
