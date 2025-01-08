import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:ftpconnect/ftpconnect.dart';
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

  Future<bool> downloadFile(String remoteFileName, String localFileName) async {
    try {
      await ftpConnect.connect();
      await ftpConnect.downloadFileWithRetry(
          remoteFileName, File(localFileName));
      print('Archivo descargado: $localFileName');
      await ftpConnect.disconnect();
      return true;
    } catch (e) {
      print('Error al descargar el archivo: $e');
      return false;
    }
  }

  static Future<String> getMessages() async {
    final response = await http.get(Uri.http(appRibGetMessagesUrlMethod));
    if (response.statusCode == 200) {
      print('Mensajes recibidos: ${response.body}');
      return response.body;
    } else {
      print('Error al obtener mensajes: ${response.statusCode}');
      return "";
    }
  }

  static Future<void> setMessageReceived() async {
    final response =
        await http.post(Uri.http(appRibSetMessageReceivedUrlMethod));
    if (response.statusCode == 200) {
      print('Mensaje recibido reportado');
    } else {
      print('Error al reportar mensaje recibido: ${response.statusCode}');
    }
  }

  static Future<void> sendMessageEntrada(String message) async {
    final response = await http.post(
      Uri.http(appRibSendMessageEntrada),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de entrada enviado');
    } else {
      print('Error al enviar mensaje de entrada: ${response.statusCode}');
    }
  }

  static Future<void> sendMessageSalida(String message) async {
    final response = await http.post(
      Uri.http(appRibSendMessageSalida),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de salida enviado');
    } else {
      print('Error al enviar mensaje de salida: ${response.statusCode}');
    }
  }

  static Future<void> deleteMessagesNewInstall() async {
    final response = await http.post(Uri.http(appRibDeleteMessagesNewInstall));
    if (response.statusCode == 200) {
      print('Mensajes borrados');
    } else {
      print('Error al borrar mensajes: ${response.statusCode}');
    }
  }

  static Future<void> sendImages(String imagePath) async {
    final response = await http.post(
      Uri.http(appRibSendImagesUrlMethod),
      body: imagePath,
    );
    if (response.statusCode == 200) {
      print('Imagen enviada');
    } else {
      print('Error al enviar imagen: ${response.statusCode}');
    }
  }
}
