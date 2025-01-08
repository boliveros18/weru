import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:weru/components/button_ui.dart';
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
  final FTPService ftpService = FTPService();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late Timer timer;
  late TextEditingController userController;
  late TextEditingController passController;

  void updatePermissionStatus(bool granted) {
    setState(() {
      permissionsGranted = granted;
    });
  }

  Future<void> downloadAndUnzipMaster(String value) async {
    final localDatabasePath = "/data/data/com.example.weru/files";
    //var/mobile/Containers/Data/Application/<App_ID>/Documents/database <--end point iOs
    Database database = await DatabaseMain(path: localDatabasePath).onCreate();
    final session = Provider.of<Session>(context, listen: false);
    // "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/master.zip"   <-- iOs
    // var/mobile/Containers/Data/Application/<App_ID>/Documents/master.zip    <--end point iOs
    final localFilePath =
        "/data/data/com.example.weru/files/MasterData" + value + ".zip";
    final localDirectoryPath = "/data/data/com.example.weru/files/MasterData";
    isLoading = true;
    session.masters = true; // await ftpService.downloadFile(
    //'${pathFTPS}' + value + '.zip', localFilePath);
    isLoading = false;
    if (session.masters) {
      //Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Archivo master descargado!")),
      );
      final input = InputFileStream(localFilePath);
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
    final session = Provider.of<Session>(context, listen: false);
    userController = TextEditingController(text: session.user);
    passController = TextEditingController(text: session.pass);
    timer = Timer.periodic(Duration(seconds: 15), (timer) async {
      //response = await FTPService.getMessages();
      String response = await rootBundle.loadString('assets/utils/init.json');
      if (session.user.isEmpty && response.isNotEmpty) {
        final data = jsonDecode(response);
        session.user = data['Tecnico'][0]['usuario'];
        session.pass = data['Tecnico'][0]['clave'];
        userController.text = session.user;
        passController.text = session.pass;
        Future.delayed(Duration.zero, () {
          DialogUi.show(
            context: context,
            title: "Se descargaron tus servicios y credenciales",
            textField: false,
            onConfirm: (value) async {},
          );
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context, listen: false);
    // if (session.nit.isEmpty) {
    Future.delayed(Duration.zero, () {
      downloadAndUnzipMaster("1");
      /*
      DialogUi.show(
        context: context,
        title: "Ingrese el nit de la organización",
        hintText: "nit",
        onConfirm: (value) async {
          setState(() {
            session.nit = value;
          });
          downloadAndUnzipMaster("1");
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          /*
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            id = iosInfo.identifierForVendor;
            */
          if (!session.deviceId) {
            (Future.delayed(Duration.zero, () {
              DialogUi.show(
                context: context,
                title: "Este es el id del dispositivo: ${androidInfo.id}",
                textField: false,
                onConfirm: (value) async {},
              );
            }));
            session.deviceId = true;
          }
        },
      );
      */
    });
    //}

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
                        //validacion con la bd
                        Navigator.pushNamed(context, '/home');
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
