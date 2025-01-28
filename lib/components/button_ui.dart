import 'package:flutter/material.dart';

class ButtonUi extends StatelessWidget {
  final String value;
  final Color color;
  final double borderRadius;
  final double fontSize;
  final Function() onClicked;

  const ButtonUi({
    super.key,
    required this.value,
    this.color = const Color(0xFF03a9f4),
    this.borderRadius = 10,
    this.fontSize = 15,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onClicked();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
