import 'package:weru/database/providers/stagemessage_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:weru/services/ftp_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/main.dart';
import 'package:weru/config/config.dart';

Future<void> onConnectionValidationStage(String message, String table) async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());
  if (connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi)) {
    await FTPService.sendMessageEntrada(message, table);
  } else {
    Database database =
        await DatabaseMain(path: await getLocalDatabasePath()).onCreate();
    final stageMessageProvider = StageMessageProvider(db: database);
    await stageMessageProvider.insert(message, table);
  }
}
