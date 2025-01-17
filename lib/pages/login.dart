import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/functions/functions.dart';
import 'package:weru/provider/session.dart';
import 'package:weru/permission_request.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool permissionsGranted = false;
  bool isLoading = false;
  late bool master;
  bool isTimerInitialized = false;
  late Session session;
  final FTPService ftpService = FTPService();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late Timer timer;
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  late Database database;
  late AndroidDeviceInfo androidInfo;
  /*
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor;
   */

  void updatePermissionStatus(bool granted) {
    setState(() {
      permissionsGranted = granted;
    });
  }

  Future<void> downloadAndUnzipMaster(String value) async {
    isLoading = true;
    master =
        true; // await ftpService.downloadFile('${pathFTPS}' + value + '.zip', localFilePath);
    isLoading = false;
    if (master) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Archivo master descargado!")),
      );
      final input = InputFileStream(await localFilePath(value));
      final archive = ZipDecoder().decodeStream(input);
      for (final file in archive) {
        if (file.isFile) {
          try {
            final output =
                OutputFileStream('${localDirectoryPath}/${file.name}');
            output.writeStream(file.getContent()!);
            insertMasterFileInSqflite(file, database);
            await file.close();
          } catch (e) {
            print('Error in file:${e}');
          }
        } else {
          try {
            await Directory('${localDirectoryPath}/${file.name}')
                .create(recursive: true);
          } catch (e) {
            print('Error in directory:${e}');
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nit errado")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    session = Provider.of<Session>(context, listen: false);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    androidInfo = await deviceInfo.androidInfo;
    database = await DatabaseMain(path: localDatabasePath).onCreate();
    timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      try {
        String response = await FTPService.getMessages(androidInfo.id);
        if (response.isEmpty) {
          return;
        }
        final data = responseXMLtoJSON(response);
        if (session.user.isEmpty &&
            data['Tecnico'] != null &&
            data['Tecnico']?[0]['usuario']?.toString().isNotEmpty == true) {
          bool insert = await insertInitMessageDataToSqflite(data, database);
          if (insert) {
            session.user = data['Tecnico']?[0]['usuario'];
            session.pass = data['Tecnico']?[0]['clave'];
            userController.text = session.user;
            passController.text = session.pass;
            Future.delayed(Duration.zero, () {
              DialogUi.show(
                context: context,
                title:
                    "Se descargaron tus servicios y credenciales. Accede a tu cuenta!",
                textField: false,
                onConfirm: (value) async {},
              );
            });
          }
        }
      } catch (e, stackTrace) {
        print('Error in _initializeApp: $e');
        print(stackTrace);
      }
    });
    isTimerInitialized = true;
  }

  @override
  void dispose() {
    if (isTimerInitialized) {
      timer.cancel();
    }
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory(localDirectoryPath).existsSync()) {
      Future.delayed(Duration.zero, () {
        DialogUi.show(
          context: context,
          title: "Ingrese el nit de la organización",
          hintText: "nit",
          onConfirm: (value) async {
            setState(() {});
            await downloadAndUnzipMaster(value);
            Navigator.of(context).pop();
            (Future.delayed(Duration.zero, () {
              DialogUi.show(
                context: context,
                title: "Este es el id del dispositivo: ${androidInfo.id}",
                textField: false,
                onConfirm: (value) async {},
              );
            }));
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
                      onPermissionStatusChanged: updatePermissionStatus,
                    ),
                  Image.asset('assets/icons/weru.png'),
                  const SizedBox(height: 20),
                  TextFieldUi(
                      hint: "Usuario",
                      prefixIcon: true,
                      prefixIconPath: "assets/icons/user.png",
                      controller: userController,
                      onChanged: (value) => session.user = value),
                  const SizedBox(height: 20),
                  TextFieldUi(
                      hint: "Contraseña",
                      prefixIcon: true,
                      prefixIconPath: "assets/icons/padlock.png",
                      controller: passController,
                      onChanged: (value) => session.pass = value),
                  const SizedBox(height: 20),
                  ButtonUi(
                      value: "Ingresar",
                      onClicked: () async {
                        bool validation = await Authentication(
                            userController.text, passController.text);
                        if (validation) {
                          session.login();
                        } else {
                          (Future.delayed(Duration.zero, () {
                            DialogUi.show(
                              context: context,
                              title: "Contraseña o usuario invalido!",
                              textField: false,
                              onConfirm: (value) async {},
                            );
                          }));
                        }
                      }),
                  const SizedBox(height: 10),
                  if (isLoading) const ProgressIndicatorUi()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
