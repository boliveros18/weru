import 'dart:convert';
import 'package:weru/functions/transform_json.dart';
import 'package:weru/services/ftp_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

Future<Map<String, List<Map<String, dynamic>>>> responseStageMessageXMLtoJSON(
    String xmlString) async {
  final document = XmlDocument.parse(xmlString);
  Future<String> TableList() async {
    return await rootBundle.loadString('assets/utils/tables.sql');
  }

  final tables = await TableList();
  final tableRegex = RegExp(r'(\w+)\s*\(([^)]+)\)');
  final matches = tableRegex.allMatches(tables);
  final Map<String, List<Map<String, dynamic>>> result = {};

  for (var match in matches) {
    final table = match.group(1)!;
    result.putIfAbsent(table, () => []);
  }

  bool AddMessage(String model, dynamic map) {
    for (var match in matches) {
      final table = match.group(1)!;
      if (model == table) {
        result[table]?.add(map);
        return true;
      }
    }
    print("Model $model not recognized.");
    return false;
  }

  for (var stageMessage in document.findAllElements('StageMessage')) {
    try {
      final id = stageMessage.findElements('Id').single.innerText;
      final body = stageMessage.findElements('Mensaje').single.innerText;
      final model =
          stageMessage.findElements('FamiliaMensaje').single.innerText;
      final map = jsonDecode(body);

      if (model == "Servicio") {
        final service = transformJson(map);
        service.forEach((key, value) {
          value.forEach((map) {
            AddMessage(key, map);
          });
        });
        FTPService.setMessageReceived(id);
      }

      final added = AddMessage(model, map);
      if (added) {
        FTPService.setMessageReceived(id);
      }
    } catch (e, stackTrace) {
      print("Error en xml to json: $e, $stackTrace");
    }
  }
  return result;
}
