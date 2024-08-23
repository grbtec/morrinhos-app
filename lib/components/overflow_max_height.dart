import 'package:flutter/material.dart';

class OverflowMaxHeight extends StatefulWidget {
  final Widget child;
  final double? heightDifference;

  OverflowMaxHeight({
    super.key,
    required this.child,
    required this.heightDifference,
  });

  @override
  State<OverflowMaxHeight> createState() => _OverflowMaxHeightState();
}

class _OverflowMaxHeightState extends State<OverflowMaxHeight> {
  BoxConstraints lastConstraints = BoxConstraints.tight(Size.zero);
  double? maxHeight = null;

  @override
  Widget build(BuildContext context) {
    final safeScreenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(Navigator.of(context).context).viewPadding.top -
        (widget.heightDifference ?? 0);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight > lastConstraints.maxHeight) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {
              maxHeight = null;
              lastConstraints = constraints;
            });
          });
        } else if (maxHeight == null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() => maxHeight = constraints.maxHeight);
          });
        }

        return OverflowBox(
          minHeight: 0,
          maxHeight: maxHeight ?? safeScreenHeight,
          alignment: Alignment.topCenter,
          child: widget.child,
        );
      },
    );
  }
}
