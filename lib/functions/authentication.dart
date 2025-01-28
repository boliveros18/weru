import 'package:sqflite/sqflite.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/models/tecnico.dart';

Future<bool> Authentication(String user, String pass) async {
  Database database =
      await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  List<Tecnico> tecnicos = await TecnicoProvider(db: database).getAll();
  Tecnico tecnico = tecnicos[0];
  if (user == tecnico.usuario && pass == tecnico.clave) {
    return true;
  }
  return false;
}
