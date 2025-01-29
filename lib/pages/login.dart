import 'dart:async';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/functions/response_stage_message_xml_to_json.dart';
import 'package:weru/functions/insert_master_file_in_sqflite.dart';
import 'package:weru/functions/insert_stage_message_list_data_to_sqflite.dart';
import 'package:weru/functions/authentication.dart';
import 'package:weru/provider/session.dart';
import 'package:weru/permission_request.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  late Timer timer;
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  late Database database;

  @override
  void initState() {
    super.initState();
    session = Provider.of<Session>(context, listen: false);
    _initializeApp();
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
            DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            IosDeviceInfo iOsInfo = await deviceInfo.iosInfo;
            await downloadAndUnzipMaster(value);
            Navigator.of(context).pop();
            (Future.delayed(Duration.zero, () {
              DialogUi.show(
                context: context,
                title:
                    "Este es el id del dispositivo: ${Platform.isAndroid ? androidInfo.id : iOsInfo.identifierForVendor}",
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
                          await session.login();
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
      final input = InputFileStream(await getLocalMasterPath(value));
      final archive = ZipDecoder().decodeStream(input);
      for (final file in archive) {
        if (file.isFile) {
          try {
            final output =
                OutputFileStream('${localDirectoryPath}/${file.name}');
            output.writeStream(file.getContent()!);
            insertMasterFileInSqflite(file, database);
            await file.close();
          } catch (e, stackTrace) {
            print('Error in file:${e}, $stackTrace');
          }
        } else {
          try {
            await Directory('${localDirectoryPath}/${file.name}')
                .create(recursive: true);
          } catch (e, stackTrace) {
            print('Error in directory:${e}, $stackTrace');
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nit errado")),
      );
    }
  }

  Future<void> _initializeApp() async {
    await currentPosition();
    database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        String response = await FTPService.getMessages();
        if (response.isEmpty) {
          return;
        }
        final data = await responseStageMessageXMLtoJSON(response);
        if (session.user.isEmpty &&
            data['Tecnico'] != null &&
            data['Tecnico']?[0]['usuario']?.toString().isNotEmpty == true) {
          bool insert =
              await insertStageMessageListDataToSqflite(data, database);
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
        print('Error in _initializeApp: $e, $stackTrace');
      }
    });
    isTimerInitialized = true;
  }
}

Future<Position> currentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  late LocationSettings locationSettings;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 5),
    );
  }
  if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.other,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
    );
  }

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await _showLocationServiceDialog();
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  Position position = await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );

  return position;
}

Future<void> _showLocationServiceDialog() async {
  return showDialog<void>(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
            'Please enable location services in your device settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
