import 'package:flutter/material.dart';

class DividerUi extends StatelessWidget {
  final double paddingHorizontal;

  const DividerUi({super.key, this.paddingHorizontal = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: Divider(
              color: const Color.fromARGB(255, 214, 214, 214),
              thickness: 1.0,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}
