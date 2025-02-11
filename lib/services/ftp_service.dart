import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'dart:io';

class FTPService {
  final FTPConnect ftpConnect = FTPConnect(
    servidorFTPS,
    user: userNameFTPS,
    pass: passwordFTPS,
    port: puertoFTPS,
    showLog: true,
    securityType: SecurityType.FTPES,
    timeout: 10,
  );

  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late String id;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iOsInfo = await deviceInfo.iosInfo;
      id = iOsInfo.identifierForVendor ?? '';
    }
    return id;
  }

  Future<bool> downloadFile(String remoteFileName, String localFileName) async {
    try {
      await ftpConnect.connect();
      await ftpConnect.downloadFileWithRetry(
          remoteFileName, File(localFileName));
      print('Archivo descargado: $localFileName');
      await ftpConnect.disconnect();
      return true;
    } catch (e, stackTrace) {
      print('Error al descargar el archivo: $e, $stackTrace');
      return false;
    }
  }

  static Future<String> getMessages() async {
    try {
      final idDevice = await getDeviceId();
      final uri = Uri.http(
        appRibGetMessagesUrlHost,
        appRibGetMessagesUrlPath + idDevice,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Error al obtener mensajes: ${response.statusCode}');
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static Future<void> setMessageReceived(String idStageMessage) async {
    try {
      final idDevice = await getDeviceId();
      final response = await http.get(
        Uri.http(
            appRibGetMessagesUrlHost,
            appRibSetMessageReceivedUrlMethod +
                idDevice +
                "/" +
                idStageMessage),
      );
      if (response.statusCode != 200) {
        print(
            'Error al reportar mensaje recibido: ${response.statusCode}, ${idStageMessage}');
      }
    } catch (e) {}
  }

  static Future<bool> sendMessageEntrada(
    String body,
    String table,
  ) async {
    final idNegocio = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
    final idDevice = await getDeviceId();
    final Map<String, dynamic> data = {
      "familiaMensaje": table,
      "tipoMensaje": "INSERT",
      "mensaje": body,
      "keyDispositivo": idDevice,
      "idNegocio": idNegocio
    };
    final formData = data.entries.map((e) {
      return '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}';
    }).join('&');

    final response = await http.post(
      Uri.http(appRibGetMessagesUrlHost, appRibSendMessageEntrada),
      headers: {"Content-Type": "text/plain"},
      body: formData,
    );

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final idEvento = document
          .findAllElements("IdEvento")
          .map((node) => node.innerText)
          .join();
      if (idEvento == "0") {
        return true;
      } else {
        return false;
      }
    } else {
      print('Error al enviar mensaje de entrada: ${response.statusCode}');
      return false;
    }
  }

  static Future<void> sendMessageSalida(String message) async {
    final response = await http.post(
      Uri.http(appRibGetMessagesUrlHost, appRibSendMessageSalida),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de salida enviado');
    } else {
      print('Error al enviar mensaje de salida: ${response.statusCode}');
    }
  }

  static Future<void> deleteMessagesNewInstall() async {
    final response = await http.post(
        Uri.http(appRibGetMessagesUrlHost, appRibDeleteMessagesNewInstall));
    if (response.statusCode == 200) {
      print('Mensajes borrados');
    } else {
      print('Error al borrar mensajes: ${response.statusCode}');
    }
  }

  static Future<void> sendImage(String imagePath) async {
    final request = http.MultipartRequest(
        "POST", Uri.http(appRibGetMessagesUrlHost, appRibSendImagesUrlMethod));
    var file = File(imagePath);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      print("Imagen enviada");
      await file.delete();
    } else {
      print('Error al enviar imagen: ${response.statusCode}');
    }
  }
}
