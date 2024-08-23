import 'package:flutter/material.dart';
import 'package:gbt_fluent2_ui/color_mode.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';

class ErrorComponent extends StatelessWidget {
  final bool discreteMode;
  final String message;
  final VoidCallback? onTryAgainClick;

  const ErrorComponent({
    super.key,
    required this.message,
    this.onTryAgainClick,
  }): discreteMode = false;

  const ErrorComponent.discrete({
    super.key,
    required this.message,
    this.onTryAgainClick,
  }):discreteMode = true;

  Widget conditionalDiscrete({required Widget child}) {
    if (discreteMode) {
      return const SizedBox(
        height: 1,
        child: OverflowBox(
          maxHeight: 100,
          alignment: Alignment.bottomLeft,
          child: Icon(
            FluentIcons.error_circle_24_regular,
            color: FluentColors.statusDangerForeground1Rest,
          ),
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return conditionalDiscrete(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: FluentSize.size120.value),
          Icon(
            FluentIcons.error_circle_12_filled,
            color: createColorMode(Theme.of(context).brightness)(
              FluentColors.neutralBackground2Pressed,
              FluentDarkColors.neutralBackground2Pressed,
            ),
            size: 40,
          ),
          SizedBox(height: FluentSize.size120.value),
          FluentText(
            message,
            style: FluentThemeDataModel.of(context)
                .fluentTextTheme
                ?.body1
                ?.fluentCopyWith(
                  fluentColor: createColorMode(Theme.of(context).brightness)(
                    FluentColors.neutralForeground2Rest,
                    FluentDarkColors.neutralForeground2Rest,
                  ),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: FluentSize.size160.value),
          if (onTryAgainClick != null)
            FluentButton(
              variant: FluentButtonVariant.outline,
              title: "Tentar Novamente",
              onPressed: onTryAgainClick,
            ),
        ],
      ),
    );
  }
}
