import 'package:flutter/material.dart';

class TextFieldUi extends StatelessWidget {
  final String hint;
  final bool prefixIcon;
  final String? prefixIconPath;
  final TextEditingController? controller;

  const TextFieldUi({
    super.key,
    required this.hint,
    this.prefixIcon = false,
    this.prefixIconPath,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: const Color(0xff1D1617).withOpacity(0.11),
          blurRadius: 20,
          spreadRadius: 0.0,
        ),
      ]),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xffDDDADA),
              fontSize: 18,
              fontWeight: FontWeight.w300),
          prefixIcon: prefixIcon && prefixIconPath != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Image.asset(
                      prefixIconPath!,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
