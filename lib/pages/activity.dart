import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/dropdown_menu_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/actividad.dart';
import 'package:weru/database/models/actividadservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/actividad_provider.dart';
import 'package:weru/database/providers/actividadservicio_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Actividad> activities;
  late List<ActividadServicio> activitiesService;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    session = Provider.of<Session>(context, listen: false);
    index = session.indexServicio;
  }

  Future<void> initializeDatabase() async {
    databaseMain = DatabaseMain(path: await getLocalDatabasePath());
    database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    await databaseMain.getServices();
    await databaseMain.getActivities();
    activities = await ActividadProvider(db: database).getAll();
    activitiesService = await databaseMain.activitiesServices;
    service = databaseMain.services[index];
    setState(() {
      isLoading = false;
      servicioProvider = ServicioProvider(db: database);
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
        header: "Actividades",
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [AppStatus(), Section()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column Section() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            DropdownMenuUi(
              list: activities.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Actividad",
              onConfirm: (id, value) async {
                Actividad activity =
                    await ActividadProvider(db: database).getItemById(id);
                bool isEqual = await databaseMain.activitiesServices
                    .any((_new) => _new.idActividad == id);
                if (!isEqual) {
                  ActividadServicio actividadServicio = ActividadServicio(
                    idServicio: service.id,
                    idActividad: id,
                    cantidad: 1,
                    costo: activity.costo,
                    valor: activity.valor,
                    ejecutada: 0,
                  );
                  await ActividadServicioProvider(db: database)
                      .insert(actividadServicio);
                  await databaseMain.getActivities();
                  setState(() {});
                }
              },
            ),
            Text("2. Lista de agregados (${databaseMain.activities.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 120,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.activities.length) {
                            final _new = databaseMain.activities[index];
                            final ejecutada = databaseMain.activitiesServices
                                .where((item) => item.idActividad == _new.id)
                                .first
                                .ejecutada;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 5),
                                          TextUi(
                                              text: 'Código: ${_new.id}',
                                              fontSize: 15),
                                          TextUi(
                                              text:
                                                  'Nombre: ${_new.descripcion}',
                                              fontSize: 15),
                                          Row(
                                            children: [
                                              TextUi(
                                                text:
                                                    'Estado:  ${ejecutada == 1 ? 'Activa' : 'Inactiva'}',
                                                long: 40,
                                                fontSize: 15,
                                              ),
                                              SizedBox(
                                                  width:
                                                      ejecutada == 1 ? 19 : 5),
                                              SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: Checkbox(
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  checkColor: Colors.white,
                                                  value: ejecutada == 1,
                                                  onChanged:
                                                      (bool? value) async {
                                                    ActividadServicio
                                                        activityService =
                                                        await ActividadServicioProvider(
                                                                db: database)
                                                            .getItemByIdActividad(
                                                                _new.id);
                                                    Map<String, Object?>
                                                        activityService2 =
                                                        activityService.toMap();
                                                    activityService2[
                                                            'ejecutada'] =
                                                        ejecutada == 1 ? 0 : 1;
                                                    ActividadServicio
                                                        activityService2Update =
                                                        ActividadServicio.fromMap(
                                                            activityService2);
                                                    await ActividadServicioProvider(
                                                            db: database)
                                                        .update(
                                                            activityService2Update);
                                                    await databaseMain
                                                        .getActivities();
                                                    setState(() {
                                                      value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: IconButton(
                                            onPressed: () async {
                                              try {
                                                await ActividadServicioProvider(
                                                        db: database)
                                                    .deleteByIdActividad(
                                                        _new.id);
                                                await databaseMain
                                                    .getActivities();
                                                setState(() {});
                                              } catch (e) {
                                                print("Error al eliminar: $e");
                                              }
                                            },
                                            icon: SvgPicture.asset(
                                              "assets/icons/trash-can-regular.svg",
                                              width: 27,
                                              height: 27,
                                              colorFilter: ColorFilter.mode(
                                                const Color.fromARGB(
                                                    255, 255, 118, 108),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                                DividerUi(
                                  paddingHorizontal: 0,
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: databaseMain.activities.length,
                      )),
                )
              ],
            ),
            if (isLoading) const ProgressIndicatorUi()
          ],
        ),
      ],
    );
  }
}
