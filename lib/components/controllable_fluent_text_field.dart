import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';

class ControllableFluentTextField extends StatefulWidget {
  final FluentTextFieldController? controller;
  final String? value;
  final void Function(String text) onChanged;
  final String? error;
  final Widget Function(
    BuildContext context,
      FluentTextFieldController controller,
      String? error,
  ) builder;

  const ControllableFluentTextField({
    super.key,
    this.controller,
    required this.value,
    required this.onChanged,
    this.error,
    required this.builder,
  });

  factory ControllableFluentTextField.fluentTextField({
    Key? key,
    required String? value,
    required void Function(String text) onChanged,
    final String? error,
    FluentTextFieldController? controller,
    String? hintText,
    String? assistiveText,
    String? label,
    Icon? suffixIcon,
    bool readOnly = false,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return ControllableFluentTextField(
      key: key,
      controller: controller,
      value: value,
      onChanged: onChanged,
      error: error,
      builder: (context, controller, error) {
        return FluentTextField(
          controller: controller,
          hintText: hintText,
          assistiveText: error??assistiveText,
          label: label,
          suffixIcon: suffixIcon,
          onChanged: onChanged,
          readOnly: readOnly,
          hasError: error!=null,
          obscureText: obscureText,
          maxLines: maxLines,
        );
      },
    );
  }

  @override
  State<ControllableFluentTextField> createState() =>
      _ControllableFluentTextFieldState();
}

class _ControllableFluentTextFieldState extends State<ControllableFluentTextField> {
  late final FluentTextFieldController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? _InternalFluentTextFieldController();
    controller.textEditingController.text = widget.value??"";
    controller.textEditingController.addListener(controllerListener);
  }

  void controllerListener() {
    widget.onChanged(controller.textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.value != controller.textEditingController.text) {
        controller.textEditingController.text = widget.value ?? "";
      }
    });
    return widget.builder(context, controller, widget.error);
  }

  @override
  void dispose() {
    if (controller is _InternalFluentTextFieldController) {
      controller.dispose();
    } else {
      controller.textEditingController.removeListener(controllerListener);
    }
    super.dispose();
  }
}

class _InternalFluentTextFieldController extends FluentTextFieldController {}
