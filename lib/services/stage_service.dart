import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/stagemessage.dart';
import 'package:weru/database/providers/stagemessage_provider.dart';
import 'package:weru/database/main.dart';
import 'package:weru/services/ftp_service.dart';

class StageService {
  StageService();

  static Future<Database> database() async {
    return await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
  }

  static Future<void> sendStageMessages2Server() async {
    List<StageMessage> items =
        await StageMessageProvider(db: await database()).getAll();

    for (final item in items) {
      String message = item.Message;
      String table = item.MessageFamily;
      await FTPService.sendMessageEntrada(jsonEncode(message), table);
    }
  }
}
