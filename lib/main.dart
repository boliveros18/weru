import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:weru/functions/authentication.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final session = Provider.of<Session>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const HomePage(),
      /*
      FutureBuilder<bool>(
        future: Authentication(session.user, session.pass),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
      */
    );
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
  Database database = await DatabaseMain(path: localDatabasePath).onCreate();
  LocationPermission permission;
  bool internet = false;

  Timer.periodic(Duration(seconds: 5), (timer) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      internet = true;
    } else {
      internet = false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    final double latitud = position.latitude;
    final double longitud = position.longitude;
    final String fechaPulso =
        DateFormat("MMM dd yyyy  h:mma").format(DateTime.now());
    List<Tecnico> technicians = await TecnicoProvider(db: database).getAll();
    Map<String, Object?> technician = technicians[0].toMap();
    technician['latitud'] = latitud;
    technician['longitud'] = longitud;
    technician['fechaPulso'] = fechaPulso;
    Tecnico updated = Tecnico.fromMap(technician);
    TecnicoProvider(db: database).insert(updated);

    if (internet) {
      try {
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
              //Crear una tabla manual en weru.db llamada Pulso
              /*
              bool sended =
                  await FTPService.sendMessageEntrada(technician, 'Tecnico');
              if (sended) {
                await PulsoProvider(db: database).delete(pulse.id);
              }
              */
            }
          }
          // await FTPService.sendMessageEntrada(technician, 'Tecnico');
        }
      } catch (e, stackTrace) {
        print('Error in background process: $e, $stackTrace');
      }
    } else {
      try {
        await PulsoProvider(db: database).insert(Pulso(
          idTecnico: updated.id,
          latitud: latitud,
          longitud: longitud,
          fechaPulso: fechaPulso,
        ));
      } catch (e) {
        print('Error al insertar pulso: $e');
      }
    }
  });
}
