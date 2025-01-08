import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarUi extends StatelessWidget implements PreferredSizeWidget {
  final String header;
  final bool prefixIcon;
  final double prefixIconHeight;
  final double prefixIconWidth;
  final String prefixIconPath;
  final bool menuIcon;
  final bool leading;
  final bool centerTitle;

  const AppBarUi(
      {super.key,
      this.header = "",
      this.prefixIcon = false,
      this.prefixIconHeight = 15,
      this.prefixIconWidth = 15,
      this.prefixIconPath = "",
      this.menuIcon = false,
      this.leading = true,
      this.centerTitle = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: leading,
      title: Text(
        header,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      centerTitle: centerTitle,
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
                  height: prefixIconHeight,
                  width: prefixIconWidth,
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
                    'assets/icons/ellipsis-vertical-solid.svg',
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
