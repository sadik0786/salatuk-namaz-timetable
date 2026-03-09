import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDirection? textDirection;

  const TrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      style: style ?? const TextStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
    );
  }
}
