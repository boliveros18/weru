import 'package:flutter/material.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/permission_request.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:weru/config/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool permissionsGranted = false;
  String nit = "";
  bool masters = false;
  final FTPService ftpService = FTPService();

  void _updatePermissionStatus(bool granted) {
    setState(() {
      permissionsGranted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nit.isEmpty) {
      Future.delayed(Duration.zero, () {
        DialogUi.show(
          context: context,
          title: "Ingrese el nit de la organización",
          hintText: "NIT",
          onConfirm: (value) async {
            setState(() {
              nit = value;
            });
            Navigator.of(context).pop();
            //"\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/master.zip"   <-- iOs
            ///var/mobile/Containers/Data/Application/<App_ID>/Documents/master.zip    <--end point iOs
            final localFilePath =
                '/data/data/com.example.weru/files/master.zip';
            await ftpService.downloadFile(
                '${pathFTPS}' + value + '.zip', localFilePath);
          },
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!permissionsGranted)
                    PermissionRequest(
                      onPermissionStatusChanged: _updatePermissionStatus,
                    ),
                  Image.asset('assets/icons/weru.png'),
                  const SizedBox(height: 20),
                  const TextFieldUi(
                    hint: "Usuario",
                    prefixIcon: true,
                    prefixIconPath: "assets/icons/user.png",
                  ),
                  const SizedBox(height: 20),
                  const TextFieldUi(
                    hint: "Contraseña",
                    prefixIcon: true,
                    prefixIconPath: "assets/icons/padlock.png",
                  ),
                  const SizedBox(height: 20),
                  const ButtonUi(value: "Ingresar"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
