import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'dart:io';

class FTPService {
  final FTPConnect ftpConnect = FTPConnect(
    servidorFTPS,
    user: userNameFTPS,
    pass: passwordFTPS,
    port: int.parse(puertoFTPS),
    showLog: true,
    securityType: SecurityType.FTPES,
    timeout: 10,
  );

  Future<void> downloadFile(String remoteFileName, String localFileName) async {
    try {
      await ftpConnect.connect();
      await ftpConnect.downloadFileWithRetry(
          remoteFileName, File(localFileName));
      print('Archivo descargado: $localFileName');
      await ftpConnect.disconnect();
    } catch (e) {
      print('Error al descargar el archivo: $e');
    }
  }

  Future<void> getMessages() async {
    final response = await http.get(
        Uri.http('nansoft.co:87', '/PruebaWeruC/RibWeb.svc/REST/QueHayNuevo'));
    if (response.statusCode == 200) {
      print('Mensajes recibidos: ${response.body}');
    } else {
      print('Error al obtener mensajes: ${response.statusCode}');
    }
  }

  Future<void> setMessageReceived() async {
    final response = await http.post(Uri.http('nansoft.co:87',
        '/PruebaWeruC/RibWeb.svc/REST/ReportarMensajeRecibido'));
    if (response.statusCode == 200) {
      print('Mensaje recibido reportado');
    } else {
      print('Error al reportar mensaje recibido: ${response.statusCode}');
    }
  }

  Future<void> sendMessageEntrada(String message) async {
    final response = await http.post(
      Uri.http(
          'nansoft.co:87', '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStream'),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de entrada enviado');
    } else {
      print('Error al enviar mensaje de entrada: ${response.statusCode}');
    }
  }

  Future<void> sendMessageSalida(String message) async {
    final response = await http.post(
      Uri.http('nansoft.co:87',
          '/PruebaWeruC/RibWeb.svc/REST/RecibirMensajeStreamSalida'),
      body: message,
    );
    if (response.statusCode == 200) {
      print('Mensaje de salida enviado');
    } else {
      print('Error al enviar mensaje de salida: ${response.statusCode}');
    }
  }

  Future<void> deleteMessagesNewInstall() async {
    final response = await http.post(Uri.http(
        'nansoft.co:87', '/PruebaWeruC/RibWeb.svc/REST/BorrarMensajesTableta'));
    if (response.statusCode == 200) {
      print('Mensajes borrados');
    } else {
      print('Error al borrar mensajes: ${response.statusCode}');
    }
  }

  Future<void> sendImages(String imagePath) async {
    final response = await http.post(
      Uri.http('nansoft.co:87', '/PruebaWeruC/RibWeb.svc/REST/RecibirImagen'),
      body: imagePath,
    );
    if (response.statusCode == 200) {
      print('Imagen enviada');
    } else {
      print('Error al enviar imagen: ${response.statusCode}');
    }
  }
}
