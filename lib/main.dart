import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:weru/functions/current_situation.dart';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/login.dart';
import 'package:weru/provider/session.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:weru/functions/insert_stage_message_list_data_to_sqflite.dart';
import 'package:weru/functions/response_stage_message_xml_to_json.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/main.dart';
import 'package:weru/config/config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weru/database/providers/pulso_provider.dart';
import 'package:weru/database/models/pulso.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/models/tecnico.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:weru/services/stage_service.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
const MethodChannel backgroundChannel = MethodChannel('background_channel');
bool? lastInternetStatus;
bool? lastGpsStatus;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkAndRequestLocationPermissions();
  await initializeService();
  startBackgroundService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Session> _initializeSession() async {
    final session = Session();
    await session.loadSession();
    return session;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session>(
      future: _initializeSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return ChangeNotifierProvider<Session>.value(
          value: snapshot.data!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Poppins'),
            home: Consumer<Session>(
              builder: (context, session, _) {
                return session.isAuthenticated
                    ? const HomePage()
                    : const LoginPage();
              },
            ),
          ),
        );
      },
    );
  }
}

Future<void> checkAndRequestLocationPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    print('Permissions are permanently denied. Cannot request permissions.');
  } else if (permission == LocationPermission.denied) {
    print('Permissions are denied.');
  }
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future<void> pulseStageInsert(Database database, Tecnico updated,
    double latitud, double longitud, String fechaPulso) async {
  await PulsoProvider(db: database).insert(Pulso(
    idTecnico: updated.id,
    latitud: latitud,
    longitud: longitud,
    fechaPulso: fechaPulso,
  ));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Servicio en ejecución",
      content: "Este servicio se ejecuta en segundo plano",
    );
  }
  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process is now stopped");
  });

  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();

  final ReceivePort waitPort = ReceivePort();
  IsolateNameServer.removePortNameMapping('onstart_service_port');
  IsolateNameServer.registerPortWithName(
      waitPort.sendPort, 'onstart_service_port');

  String deviceName;
  String platformVersion;

  LocationSettings locationSettings;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 10),
    );
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceName = androidInfo.model;
    platformVersion =
        RegExp(r'(\d+\.\d+\.\d+)').firstMatch(Platform.version)?.group(1) ??
            "Not Found";
  } else if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.other,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
    );
    IosDeviceInfo iOsInfo = await deviceInfo.iosInfo;
    deviceName = iOsInfo.modelName;
    platformVersion =
        RegExp(r'(\d+\.\d+\.\d+)').firstMatch(Platform.version)?.group(1) ??
            "Not Found";
  } else {
    print('Plataforma no soportada para obtener ubicaciones.');
    return;
  }

  waitPort.listen((message) {
    if (message == "ready") {
      Timer.periodic(const Duration(seconds: 40), (timer) async {
        final List<ConnectivityResult> connectivityResult =
            await (Connectivity().checkConnectivity());

        bool currentInternetStatus =
            connectivityResult.contains(ConnectivityResult.mobile) ||
                connectivityResult.contains(ConnectivityResult.wifi);

        if (lastInternetStatus != currentInternetStatus) {
          lastInternetStatus = currentInternetStatus;
          if (currentInternetStatus) {
            await currentSituation("ModoAvion-Desactivado");
          } else {
            await currentSituation("ModoAvion-Activado");
          }
        }

        if (connectivityResult.contains(ConnectivityResult.wifi)) {
          if (lastInternetStatus != true) {
            await currentSituation("Señal-Activada");
          }
        } else if (connectivityResult.contains(ConnectivityResult.none)) {
          if (lastInternetStatus != false) {
            await currentSituation("Señal-Desactivada");
          }
        }

        Geolocator.getServiceStatusStream()
            .listen((ServiceStatus status) async {
          bool gpsEnabled = (status == ServiceStatus.enabled);

          if (lastGpsStatus != gpsEnabled) {
            lastGpsStatus = gpsEnabled;
            await currentSituation(
                gpsEnabled ? "Gps-Activado" : "Gps-Desactivado");
          }
        });

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        final double latitud = position.latitude;
        final double longitud = position.longitude;
        final String fechaPulso =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        final String versionApp =
            '4.1 ${Platform.isAndroid ? "- SDK:" : "- iOs:"} ${platformVersion} - Equipo: ${deviceName}';

        if (!Directory(await getLocalDatabasePathFile()).existsSync()) {
          List<Tecnico> technicians =
              await TecnicoProvider(db: database).getAll();
          if (technicians.isNotEmpty) {
            Map<String, Object?> technician = technicians[0].toMap();
            technician['latitud'] = latitud;
            technician['longitud'] = longitud;
            technician['fechaPulso'] = fechaPulso;
            technician['versionApp'] = versionApp;
            Tecnico updated = Tecnico.fromMap(technician);
            TecnicoProvider(db: database).insert(updated);

            if (currentInternetStatus) {
              try {
                String message = await FTPService.getMessages();
                if (message.isNotEmpty) {
                  final data = await responseStageMessageXMLtoJSON(message);
                  await insertStageMessageListDataToSqflite(data, database);
                  if (data['Servicio']!.isNotEmpty) {
                    SendPort? uiSendPort =
                        IsolateNameServer.lookupPortByName('service_port');
                    if (uiSendPort != null) {
                      uiSendPort.send("servicio");
                    }
                  }
                  List<Pulso> pulses =
                      await PulsoProvider(db: database).getAll();
                  if (pulses.isNotEmpty) {
                    for (final pulse in pulses) {
                      technician['latitud'] = pulse.latitud;
                      technician['longitud'] = pulse.longitud;
                      technician['fechaPulso'] = pulse.fechaPulso;
                      bool sent = await FTPService.sendMessageEntrada(
                          jsonEncode(technician), 'Tecnico');
                      if (sent) {
                        await PulsoProvider(db: database).delete(pulse.id!);
                      }
                    }
                  }
                  await FTPService.sendMessageEntrada(
                      jsonEncode(technician), 'Tecnico');
                  await StageService.sendStageMessages2Server();
                }
              } catch (e) {
                if (e.toString().contains("Connection timed out") ||
                    e.toString().contains("Failed host lookup")) {
                  await currentSituation("Señal-Desactivada");
                  await pulseStageInsert(
                      database, updated, latitud, longitud, fechaPulso);
                }
              }
            } else {
              try {
                await pulseStageInsert(
                    database, updated, latitud, longitud, fechaPulso);
              } catch (e) {
                print('Error al insertar pulso: $e');
              }
            }
          }
        }
      });
    }
  });
}