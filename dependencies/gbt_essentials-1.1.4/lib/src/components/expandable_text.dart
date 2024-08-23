// Original source: https://prafullkumar77.medium.com/how-to-set-read-more-less-in-flutter-d601cf313a33
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final String showMoreText;
  final Color? showMoreColor;
  final String showLessText;
  final void Function(bool newShowReadMoreText)? didStateChange;
  final String? fallbackHighlight;

  const ExpandableText({
    required this.text,
    required this.trimLines,
    this.showMoreText = "mostrar mais",
    this.showLessText = "mostrar menos",
    this.style,
    this.fallbackHighlight,
    this.showMoreColor,
    this.didStateChange,
    Key? key,
  }) : super(key: key);

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _showReadMoreText = true;

  final focusNode = FocusNode();

  ExpandableTextState();

  onTapLink() {
    final didStateChange = widget.didStateChange;

    focusNode.requestFocus();


      setState(() {
        _showReadMoreText = !_showReadMoreText;
        if (didStateChange != null) didStateChange(_showReadMoreText);
      });

  }

  @override
  void initState() {
    focusNode.addListener(() {
      // final hasFocus = focusNode.hasFocus;
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final textStyle = widget.style ?? defaultTextStyle.style;

    TextSpan link = TextSpan(
      text: _showReadMoreText ? "... " : " ",
      style: textStyle,
      children: [
        TextSpan(
          children: [
            TextSpan(
              text:
                  _showReadMoreText ? widget.showMoreText : widget.showLessText,
              style: TextStyle(
                  color: widget.showMoreColor ?? theme.primaryColor,
                  fontWeight: FontWeight.w800),
              recognizer: TapGestureRecognizer()..onTap = onTapLink,
            ),
            // Fix width of previous gesture recognizer TextSpan
            TextSpan(
              text: " ", //Hair Space https://www.compart.com/en/unicode/U+200A
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // 📝 Capture and ignore taps in this area (remain area after the text)
                },
            ),
          ],
        )
      ],
    );
    TextSpan? fallbackHighlight = widget.fallbackHighlight == null
        ? null
        : TextSpan(
            text: " ",
            style: textStyle,
            children: [
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.fallbackHighlight,
                    style: TextStyle(
                      color: widget.showMoreColor ?? theme.primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTapLink,
                  ),
                  // Fix width of previous gesture recognizer TextSpan
                  TextSpan(
                    text:
                        " ", //Hair Space https://www.compart.com/en/unicode/U+200A
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // 📝 Capture and ignore taps in this area (remain area after the text)
                      },
                  ),
                ],
              )
            ],
          );
    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
          style: textStyle,
        );
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,
          //better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        TextSpan textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: _showReadMoreText
                ? widget.text.substring(0, endIndex)
                : widget.text,
            style: textStyle,
            children: <TextSpan>[link],
          );
        } else if (fallbackHighlight != null) {
          textSpan = TextSpan(
              text: widget.text,
              style: textStyle,
              children: [fallbackHighlight]);
        } else {
          textSpan = TextSpan(
            text: widget.text,
            style: textStyle,
          );
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        print("hasFocus: $hasFocus");
        setState(() {
          _showReadMoreText = !hasFocus;
        });
      },
      child: result,
    );
  }
}
