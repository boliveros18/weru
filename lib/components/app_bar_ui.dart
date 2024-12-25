import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final String header;
  final bool prefixIcon;
  final String prefixIconPath;
  final bool menuIcon;

  const AppBarUi({
    super.key,
    this.header = "",
    this.prefixIcon = false,
    this.prefixIconPath = "",
    this.menuIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        header,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: true,
      leading: prefixIcon
          ? GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Acción para regresar
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffF7F8F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  prefixIconPath,
                  height: 15,
                  width: 15,
                ),
              ),
            )
          : null,
      actions: menuIcon
          ? [
              GestureDetector(
                onTap: () {
                  // Acción para el botón de la derecha
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F8F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/ellipsis-solid.svg',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
