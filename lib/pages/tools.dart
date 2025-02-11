import 'package:flutter_svg/flutter_svg.dart';
import 'package:weru/components/app_bar_ui.dart';
import 'package:flutter/material.dart';
import 'package:weru/components/app_status.dart';
import 'package:weru/components/dialog_ui.dart';
import 'package:weru/components/divider_ui.dart';
import 'package:weru/components/progress_indicator_ui.dart';
import 'package:weru/components/dropdown_menu_ui.dart';
import 'package:weru/components/text_ui.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/models/item.dart';
import 'package:weru/database/models/maletin.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/maletin_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/provider/session.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late DatabaseMain databaseMain;
  late Session session;
  int index = 0;
  bool isLoading = true;
  late ServicioProvider servicioProvider;
  late Servicio service;
  late Database database;
  late List<Item> tools;
  late List<Maletin> briefcase;

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
    service = databaseMain.services[index];
    await databaseMain.getTools(service.idTecnico);
    tools = await ItemProvider(db: database).getAllByType(2);
    briefcase = await databaseMain.briefcase;
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
        header: "Heramientas",
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
          children: [
            const SizedBox(height: 20),
            DropdownMenuUi(
              hint: "Cantidad",
              textfield: true,
              list: tools.map((item) {
                return DropDownValueModel(
                  name: item.descripcion,
                  value: item.id,
                );
              }).toList(),
              title: "Herramienta",
              onConfirm: (id, value) async {
                if (int.tryParse(value) != null) {
                  Item tool = await ItemProvider(db: database).getItemById(id);
                  bool isEqual = await databaseMain.briefcase
                      .any((_new) => _new.idItem == id);
                  if (!isEqual) {
                    Maletin briefcase = Maletin(
                        idTecnico: service.idTecnico,
                        idItem: id,
                        cantidad: int.parse(value),
                        costo: tool.costo.toDouble(),
                        valor: tool.precio.toDouble());
                    await MaletinProvider(db: database).insert(briefcase);
                    await databaseMain.getTools(service.idTecnico);
                    setState(() {});
                  }
                } else {
                  (Future.delayed(Duration.zero, () {
                    DialogUi.show(
                      textField: false,
                      context: context,
                      title: 'Escribe un numero valido!',
                      onConfirm: (value) async {},
                    );
                  }));
                }
              },
            ),
            Text("2. Lista de agregados (${databaseMain.tools.length}): ",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)),
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.width - 120,
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          if (index < databaseMain.tools.length) {
                            final _new = databaseMain.tools[index];
                            final _tool = databaseMain.briefcase
                                .where((item) => item.idItem == _new.id)
                                .first;
                            return GestureDetector(
                                onTap: () {
                                  (Future.delayed(Duration.zero, () {
                                    DialogUi.show(
                                      hintText: "Cantidad",
                                      context: context,
                                      title:
                                          'Edita el campo de cantidad de este item: ${_new.descripcion}',
                                      textField: true,
                                      onConfirm: (value) async {
                                        if (int.tryParse(value) != null) {
                                          Map<String, Object?> toolItem =
                                              _tool.toMap();
                                          toolItem['cantidad'] = value;
                                          Maletin updated =
                                              Maletin.fromMap(toolItem);
                                          await MaletinProvider(db: database)
                                              .update(updated);
                                          await databaseMain
                                              .getTools(service.idTecnico);
                                          setState(() {});
                                        } else {
                                          (Future.delayed(Duration.zero, () {
                                            DialogUi.show(
                                              textField: false,
                                              context: context,
                                              title:
                                                  'Escribe un numero valido!',
                                              onConfirm: (value) async {},
                                            );
                                          }));
                                        }
                                      },
                                    );
                                  }));
                                },
                                child: Column(
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
                                              TextUi(
                                                  text:
                                                      'Cantidad: ${_tool.cantidad}',
                                                  fontSize: 15),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                                    await MaletinProvider(
                                                            db: database)
                                                        .deleteByIdItem(
                                                            _new.id);
                                                    await databaseMain.getTools(
                                                        service.idTecnico);
                                                    setState(() {});
                                                  } catch (e) {
                                                    print(
                                                        "Error al eliminar: $e");
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
                                ));
                          } else {
                            return Container();
                          }
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemCount: databaseMain.tools.length,
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
