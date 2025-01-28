import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/button_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/text_field_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/functions/on_connection_validation_stage.dart';
import 'dart:convert';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/menu.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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
        header: "Novedades",
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
                  children: [serviceEndedSection()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column serviceEndedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            TextFieldUi(
              hint: "Descripcion",
              onChanged: (value) => session.user = value,
              minLines: 5,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            if (isLoading) const ProgressIndicatorUi()
          ],
        ),
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 1.8),
            Expanded(
              child: ButtonUi(
                value: "Enviar",
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
                color: const Color.fromARGB(255, 244, 177, 54),
                borderRadius: 0,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
