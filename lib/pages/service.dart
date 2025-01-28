import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';
import 'dart:convert';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/menu.dart';
import 'package:weru/pages/news.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late DatabaseMain databaseMain;
  late Session session;
  late int statusServiceId;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio servicio;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    session = Provider.of<Session>(context, listen: false);
    index = session.indexServicio;
  }

  Future<void> initializeDatabase() async {
    databaseMain = DatabaseMain(path: await getLocalDatabasePath());
    Database database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    await databaseMain.getServices();
    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
      statusServiceId = databaseMain.services[index].idEstadoServicio;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: ProgressIndicatorUi(),
        ),
      );
    }
    return Scaffold(
      appBar: const AppBarUi(
        header: "Servicio",
        prefixIcon: true,
        prefixIconHeight: 15,
        prefixIconWidth: 15,
        prefixIconPath: "assets/icons/chevron-left-solid.svg",
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    serviceMainSection(),
                    serviceMiddleSection(),
                    serviceEndedSection()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column serviceMainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          child: ListView.separated(
            itemBuilder: (context, index) {
              final service = databaseMain.services[index];
              final client = databaseMain.clients[index];

              return Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: TextUi(text: 'N° Servicio: ${service.orden}'),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: const Color.fromARGB(255, 0, 45, 168),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                            child: TextUi(
                              text: 'Datos del cliente',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DividerUi(paddingHorizontal: 0),
                    const SizedBox(height: 10),
                    Row(children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          SvgPicture.asset(
                            "assets/icons/pen-solid.svg",
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF03a9f4),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextUi(text: 'Dirección: ${service.direccion}'),
                            TextUi(text: 'Establecimiento: ${service.nombre}'),
                            TextUi(text: 'Telefono: ${client.celular}'),
                            TextUi(text: 'Celular: ${client.celular}'),
                          ])
                    ]),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 2,
            ),
            itemCount: databaseMain.services.length,
            scrollDirection: Axis.vertical,
          ),
        ),
      ],
    );
  }

  Column serviceMiddleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ListView.separated(
            itemBuilder: (context, index) {
              final service = databaseMain.services[index];
              final type = databaseMain.servicesTypes[index];
              final fail = databaseMain.fails[index];
              final dateTime = service.fechayhorainicio.split(' ');

              return Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      color: const Color.fromARGB(255, 0, 45, 168),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                            child: TextUi(
                              text: 'Datos del servicio',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DividerUi(paddingHorizontal: 0),
                    const SizedBox(height: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TextUi(text: 'Fecha: ${dateTime[0]}'),
                              const SizedBox(width: 30),
                              TextUi(text: 'Hora: ${dateTime[1]}'),
                            ],
                          ),
                          Row(
                            children: [
                              TextUi(text: 'N° Servicio: ${service.orden}'),
                              const SizedBox(width: 59),
                              TextUi(text: 'Radicado: ${service.radicado}')
                            ],
                          ),
                          TextUi(
                            text: 'Tipo de servicio: ${type.descripcion}',
                            long: 50,
                          ),
                          TextUi(
                            text: 'Establecimiento: ${service.nombre}',
                            long: 50,
                          ),
                          TextUi(text: 'Falla: ${fail.descripcion}'),
                          TextUi(
                              text:
                                  'Observación: ${service.observacionReporte}'),
                        ])
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 2,
            ),
            itemCount: databaseMain.services.length,
            scrollDirection: Axis.vertical,
          ),
        ),
      ],
    );
  }

  Column serviceEndedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ButtonUi(
                value: statusServiceId == 2 ? "LLEGADA A SITIO" : "INICIO",
                onClicked: () async {
                  if (statusServiceId == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(),
                      ),
                    );
                  } else {
                    final Map<String, dynamic> serviceData =
                        databaseMain.services[index].toMap();
                    serviceData['idEstadoServicio'] = 3;
                    final Servicio servicio = Servicio.fromMap(serviceData);
                    await servicioProvider.insert(servicio);
                    await onConnectionValidationStage(
                        jsonEncode(servicio.toMap()), "Servicio");
                    setState(() {
                      statusServiceId = servicio.idEstadoServicio;
                    });
                  }
                },
                borderRadius: 0,
                color: statusServiceId == 2
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF00BCD4),
              ),
            ),
            SizedBox(width: 30),
            Expanded(
              child: ButtonUi(
                value: "CANCELAR",
                onClicked: () async {
                  final Map<String, dynamic> serviceData =
                      databaseMain.services[index].toMap();
                  serviceData['idEstadoServicio'] = 7;
                  final Servicio servicio = Servicio.fromMap(serviceData);
                  await servicioProvider.insert(servicio);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                color: Colors.red,
                borderRadius: 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 1.99),
            TextUi(
              text: 'Novedades: ',
              fontSize: 15,
            ),
            Expanded(
              child: ButtonUi(
                value: "+",
                onClicked: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsPage(),
                    ),
                  )
                },
                color: const Color.fromARGB(255, 244, 177, 54),
                borderRadius: 20,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
