import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:weru/functions/authentication.dart';
import 'package:weru/functions/current_situation.dart';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/login.dart';
import 'package:weru/pages/menu.dart';
import 'package:weru/pages/news.dart';
import 'package:weru/pages/signature.dart';
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
import 'package:weru/services/stage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkAndRequestLocationPermissions();
  await initializeService();
  startBackgroundService();
  runApp(
    ChangeNotifierProvider<Session>(
      create: (context) => Session(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Session session = Provider.of<Session>(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: MenuPage()
        /*
       FutureBuilder<bool>(
          future: Authentication(session.user, session.pass),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return HomePage();
            }
            return LoginPage();
          }),
          */
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process is now stopped");
  });

  bool internet = false;
  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();

  LocationSettings locationSettings;
  if (Platform.isAndroid) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: false,
      intervalDuration: const Duration(seconds: 5),
    );
  } else if (Platform.isIOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.other,
      distanceFilter: 10,
      pauseLocationUpdatesAutomatically: false,
    );
  } else {
    print('Plataforma no soportada para obtener ubicaciones.');
    return;
  }

  Timer.periodic(Duration(seconds: 30), (timer) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      internet = true;
      await currentSituation("ModoAvion-Desactivado");
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      internet = false;
      await currentSituation("ModoAvion-Activado");
    }

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      if (status == ServiceStatus.enabled) {
        await currentSituation("Gps-Activado");
      } else {
        await currentSituation("Gps-Desactivado");
      }
    });

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    final double latitud = position.latitude;
    final double longitud = position.longitude;
    final String fechaPulso =
        DateFormat("MMM dd yyyy  h:mma").format(DateTime.now());

    if (!Directory(await getLocalDatabasePathFile()).existsSync()) {
      List<Tecnico> technicians = await TecnicoProvider(db: database).getAll();
      if (technicians.isNotEmpty) {
        Map<String, Object?> technician = technicians[0].toMap();
        technician['latitud'] = latitud;
        technician['longitud'] = longitud;
        technician['fechaPulso'] = fechaPulso;
        Tecnico updated = Tecnico.fromMap(technician);
        TecnicoProvider(db: database).insert(updated);

        Future<void> pulseStageInsert(Tecnico updated) async {
          await PulsoProvider(db: database).insert(Pulso(
            idTecnico: updated.id,
            latitud: latitud,
            longitud: longitud,
            fechaPulso: fechaPulso,
          ));
        }

        if (internet) {
          try {
            await currentSituation("Señal-Activada");
            String message = await FTPService.getMessages();
            if (message.isNotEmpty) {
              final data = await responseStageMessageXMLtoJSON(message);
              await insertStageMessageListDataToSqflite(data, database);
              List<Pulso> pulses = await PulsoProvider(db: database).getAll();
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
              await pulseStageInsert(updated);
            }
          }
        } else {
          try {
            await pulseStageInsert(updated);
          } catch (e) {
            print('Error al insertar pulso: $e');
          }
        }
      }
    }
  });
}
