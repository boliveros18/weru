import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseMain databaseMain = DatabaseMain(path: localDatabasePath);

  @override
  void initState() {
    super.initState();
    databaseMain.getServices().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarUi(
        header: "Servicios",
        prefixIcon: true,
        prefixIconHeight: 32,
        prefixIconWidth: 32,
        prefixIconPath: "assets/icon/icon.svg",
        leading: false,
        centerTitle: false,
        menuIcon: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    servicesSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column servicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 85,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return Container(
                height: 161,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  border: Border(
                    left: BorderSide(
                      color: _getStatusColor(
                          databaseMain.servicesStatus[index].nombre),
                      width: 7,
                    ),
                    bottom: BorderSide(
                      color: _getStatusColor(
                          databaseMain.servicesStatus[index].nombre),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    SvgPicture.asset(
                      "assets/icons/google-maps.svg",
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextUi(
                                text:
                                    'N° Servicio: ${databaseMain.services[index].orden}     '),
                            TextUi(
                                text:
                                    'Radicado: ${databaseMain.services[index].radicado}'),
                          ],
                        ),
                        TextUi(
                            text:
                                'Cliente:  ${databaseMain.clients[index].nombre}'),
                        TextUi(
                            text:
                                'Direccion:  ${databaseMain.services[index].direccion}'),
                        TextUi(
                            text:
                                'Ubicacion:  ${databaseMain.cities[index].nombre}'),
                        TextUi(
                            text:
                                'Equipo:  ${databaseMain.equipments[index].nombre}'),
                        TextUi(
                            text:
                                'Modelo:  ${databaseMain.models[index].descripcion}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextUi(
                                text:
                                    'Fecha:  ${databaseMain.services[index].fechayhorainicio.split(' ')[0]}     '),
                            TextUi(
                                text:
                                    'Hora:  ${databaseMain.services[index].fechayhorainicio.split(' ')[1]}'),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          color: _getStatusColor(
                              databaseMain.servicesStatus[index].nombre),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                            child: TextUi(
                              text:
                                  '${databaseMain.servicesStatus[index].nombre}',
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
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
        )
      ],
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case "Por asignar":
      return const Color.fromARGB(255, 0, 45, 168);
    case "Por ejecutar":
      return const Color(0xFF4CAF50);
    case "En ejecucion":
      return const Color(0xFFFFC107);
    case "Con novedad":
      return const Color(0xFF2196F3);
    case "Finalizado":
      return const Color(0xFF8BC34A);
    case "Anulado":
      return const Color(0xFFF44336);
    case "Cancelado":
      return const Color(0xFF9E9E9E);
    case "Vencido":
      return const Color(0xFFB71C1C);
    case "Fallido":
      return const Color(0xFF757575);
    case "En sitio":
      return const Color(0xFF00BCD4);
    case "Por Transmitir":
      return const Color(0xFFFF5722);
    default:
      return const Color.fromARGB(255, 0, 45, 168);
  }
}
