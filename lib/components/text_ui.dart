import 'package:flutter/material.dart';

class TextUi extends StatelessWidget {
  final String text;
  final Color? color;

  const TextUi({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Color(0xff7B6F72),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
