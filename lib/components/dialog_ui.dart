import 'package:flutter/material.dart';
import 'package:weru/components/text_field_ui.dart';

class DialogUi extends StatelessWidget {
  final String title;
  final String hintText;
  final Function(String) onConfirm;

  const DialogUi({
    super.key,
    required this.title,
    required this.hintText,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String hintText,
    required Function(String) onConfirm,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogUi(
          title: title,
          hintText: hintText,
          onConfirm: (value) {
            onConfirm(value);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
      ),
      content: TextFieldUi(
        hint: hintText,
        controller: textController,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              onConfirm(textController.text);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Por favor, ingrese un valor")),
              );
            }
          },
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
