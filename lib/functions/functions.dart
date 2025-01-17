import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:weru/database/models/modelo.dart';
import 'package:weru/database/providers/actividad_provider.dart';
import 'package:weru/database/providers/actividadmodelo_provider.dart';
import 'package:weru/database/providers/actividadservicio_provider.dart';
import 'package:weru/database/providers/adjuntoservicio_provider.dart';
import 'package:weru/database/providers/categoriaindicador_provider.dart';
import 'package:weru/database/providers/ciudad_provider.dart';
import 'package:weru/database/providers/cliente_provider.dart';
import 'package:weru/database/providers/diagnostico_provider.dart';
import 'package:weru/database/providers/diagnosticoservicio_provider.dart';
import 'package:weru/database/providers/equipo_provider.dart';
import 'package:weru/database/providers/estadoservicio_provider.dart';
import 'package:weru/database/providers/falla_provider.dart';
import 'package:weru/database/providers/fotoservicio_provider.dart';
import 'package:weru/database/providers/indicador_provider.dart';
import 'package:weru/database/providers/indicadormodelo_provider.dart';
import 'package:weru/database/providers/indicadorservicio_provider.dart';
import 'package:weru/database/providers/indirecto_provider.dart';
import 'package:weru/database/providers/indirectomodelo_provider.dart';
import 'package:weru/database/providers/indirectoservicio_provider.dart';
import 'package:weru/database/providers/item_provider.dart';
import 'package:weru/database/providers/itemactividadservicio_provider.dart';
import 'package:weru/database/providers/itemmodelo_provider.dart';
import 'package:weru/database/providers/itemservicio_provider.dart';
import 'package:weru/database/providers/maletin_provider.dart';
import 'package:weru/database/providers/modelo_provider.dart';
import 'package:weru/database/providers/novedad_provider.dart';
import 'package:weru/database/providers/novedadservicio_provider.dart';
import 'package:weru/database/providers/registrocamposadicionales_provider.dart';
import 'package:weru/database/providers/servicio_provider.dart';
import 'package:weru/database/providers/stagemessage_provider.dart';
import 'package:weru/database/providers/tecnico_provider.dart';
import 'package:weru/database/providers/tipocliente_provider.dart';
import 'package:weru/database/providers/tipoitem_provider.dart';
import 'package:weru/database/providers/tiposervicio_provider.dart';
import 'package:weru/database/providers/titulos_provider.dart';
import 'package:weru/database/providers/valoresindicador_provider.dart';

import 'package:weru/database/models/tecnico.dart';
import 'package:weru/database/models/actividadservicio.dart';
import 'package:weru/database/models/adjuntoservicio.dart';
import 'package:weru/database/models/diagnosticoservicio.dart';
import 'package:weru/database/models/estadoservicio.dart';
import 'package:weru/database/models/indicadorservicio.dart';
import 'package:weru/database/models/indirectoservicio.dart';
import 'package:weru/database/models/itemactividadservicio.dart';
import 'package:weru/database/models/itemservicio.dart';
import 'package:weru/database/models/novedadservicio.dart';
import 'package:weru/database/models/servicio.dart';
import 'package:weru/database/models/tiposervicio.dart';
import 'package:weru/config/config.dart';
import 'package:weru/database/main.dart';

import 'package:xml/xml.dart';

Future<void> FactoryModelsAndProviders() async {
  try {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final modelsPath = p.join(documentsDirectory.path, 'database/models');
    final providersPath = p.join(documentsDirectory.path, 'database/providers');
    final tables = await rootBundle.loadString('assets/utils/tables.sql');
    final tableRegex = RegExp(r'(\w+)\s*\(([^)]+)\)');
    final matches = tableRegex.allMatches(tables);

    for (final match in matches) {
      final tableName = match.group(1)!;
      final columns = match.group(2)!.split(',');
      final className = _capitalize(tableName);
      final fields = columns.map((col) {
        final parts = col.trim().split(' ');
        final fieldName = parts[0];
        final fieldType = _mapSqlTypeToDartType(parts[1]);
        return '  final $fieldType $fieldName;';
      }).join('\n');

      final modelConstructor = columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        return '    required this.$fieldName,';
      }).join('\n');

      final toMapEntries = columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        return "      '$fieldName': $fieldName,";
      }).join('\n');

      final modelContent = '''
class $className {
$fields

  $className({
$modelConstructor
  });

  Map<String, Object?> toMap() {
    return {
$toMapEntries
    };
  }

  @override
  String toString() {
    return '$className{${columns.map((col) => col.trim().split(' ')[0] + ': \$' + col.trim().split(' ')[0]).join(', ')}}';
  }
}
''';

      final modelFile =
          File(p.join(modelsPath, '${tableName.toLowerCase()}.dart'));
      await modelFile.create(recursive: true);
      await modelFile.writeAsString(modelContent);

      final providerContent = '''
import 'package:sqflite/sqflite.dart';
import '../models/${tableName.toLowerCase()}.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ${className}Provider {

  final Database db;
  ${className}Provider({required this.db});

  Future<void> insert($className ${tableName.toLowerCase()}) async {
    await db.insert(
      '$tableName',
      ${tableName.toLowerCase()}.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<$className>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('$tableName');
    return maps.map((map) {
      return $className(
${columns.map((col) {
        final fieldName = col.trim().split(' ')[0];
        final fieldType = _mapSqlTypeToDartType(col.trim().split(' ')[1]);
        return "        $fieldName: map['$fieldName'] as $fieldType,";
      }).join('\n')}
      );
    }).toList();
  }

  Future<void> update($className ${tableName.toLowerCase()}) async {
    await db.update(
      '$tableName',
      ${tableName.toLowerCase()}.toMap(),
      where: 'id = ?',
      whereArgs: [${tableName.toLowerCase()}.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      '$tableName',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

Future<void> insertInitFile(ArchiveFile file) async {
  List<int> bytes = file.content;
  String fileContent = utf8.decode(bytes);
  List<String> lines = fileContent.split('\\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      $className ${tableName.toLowerCase()} = $className(
          ${columns.map((col) {
        final parts = col.trim().split(' ');
        final fieldName = parts[0];
        final fieldType = _mapSqlTypeToDartType(parts[1]);
        if (fieldType == "String") {
          return "$fieldName: parts[${columns.indexOf(col)}].trim(),";
        } else {
          return "$fieldName: $fieldType.parse(parts[${columns.indexOf(col)}].trim()),";
        }
      }).join('\n')}
        );
      await db.transaction((database) async {
        await database.insert(
          '$tableName',
          ${tableName.toLowerCase()}.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
''';

      final providerFile = File(
          p.join(providersPath, '${tableName.toLowerCase()}_provider.dart'));
      await providerFile.create(recursive: true);
      await providerFile.writeAsString(providerContent);
    }
  } catch (e) {
    print('Error generating models and providers:${e}');
  }
}

String _capitalize(String input) {
  return input[0].toUpperCase() + input.substring(1);
}

String _mapSqlTypeToDartType(String sqlType) {
  final type = sqlType.toUpperCase();
  if (type.startsWith('DECIMAL')) {
    return 'Decimal';
  }
  switch (type) {
    case 'INTEGER':
      return 'int';
    case 'INT':
      return 'int';
    case 'TEXT':
      return 'String';
    case 'REAL':
      return 'Decimal';
    case 'DATETIME':
      return 'DateTime';
    default:
      return 'Object';
  }
}

Future<bool> insertInitMessageDataToSqflite(
    dynamic data, Database database) async {
  final tecnicoProvider = TecnicoProvider(db: database);
  final actividadServicioProvider = ActividadServicioProvider(db: database);
  final adjuntoServicioProvider = AdjuntoServicioProvider(db: database);
  final diagnosticoServicioProvider = DiagnosticoServicioProvider(db: database);
  final estadoServicioProvider = EstadoServicioProvider(db: database);
  final indicadorServicioProvider = IndicadorServicioProvider(db: database);
  final indirectoServicioProvider = IndirectoServicioProvider(db: database);
  final itemActividadServicioProvider =
      ItemActividadServicioProvider(db: database);
  final itemServicioProvider = ItemServicioProvider(db: database);
  final novedadServicioProvider = NovedadServicioProvider(db: database);
  final servicioProvider = ServicioProvider(db: database);
  final tipoServicioProvider = TipoServicioProvider(db: database);
  final modeloProvider = ModeloProvider(db: database);

  for (var map in data['Tecnico'] ?? []) {
    final tecnico = Tecnico(
      id: map['id'] as int,
      cedula: map['cedula'] as String,
      nombre: map['nombre'] as String,
      idProveedor: map['idProveedor'] as int,
      idEstadoTecnico: map['idEstadoTecnico'] as int,
      usuario: map['usuario'] as String,
      clave: map['clave'] as String,
      telefono: map['telefono'] as String,
      celular: map['celular'] as String,
      latitud: map['latitud'] as double,
      longitud: map['longitud'] as double,
      androidID: map['androidID'] as String,
      fechaPulso: map['fechaPulso'] as String,
      versionApp: map['versionApp'] as String,
    );
    await tecnicoProvider.insert(tecnico);
  }

  for (var map in data['Modelo'] ?? []) {
    final modelo = Modelo(
      id: map['id'] as int,
      descripcion: map['descripcion'] as String,
    );
    await modeloProvider.insert(modelo);
  }

  for (var map in data['ActividadServicio'] ?? []) {
    final actividadServicio = ActividadServicio(
      id: map['id'] as int,
      idActividad: map['idActividad'] as int,
      idServicio: map['idServicio'] as String,
      cantidad: map['cantidad'] as int,
      costo: map['costo'] as int,
      valor: map['valor'] as int,
      ejecutada: map['ejecutada'] as int,
    );
    await actividadServicioProvider.insert(actividadServicio);
  }

  for (var map in data['AdjuntoServicio'] ?? []) {
    final adjuntoServicio = AdjuntoServicio(
      id: map['id'] as int,
      idServicio: map['idServicio'] as String,
      idTecnico: map['idTecnico'] as int,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      tipo: map['tipo'] as String,
    );
    await adjuntoServicioProvider.insert(adjuntoServicio);
  }

  for (var map in data['DiagnosticoServicio'] ?? []) {
    final diagnosticoServicio = DiagnosticoServicio(
      id: map['id'] as int,
      idServicio: map['idServicio'] as int,
      idDiagnostico: map['idDiagnostico'] as int,
    );
    await diagnosticoServicioProvider.insert(diagnosticoServicio);
  }

  for (var map in data['EstadoServicio'] ?? []) {
    final estadoServicio = EstadoServicio(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
    );
    await estadoServicioProvider.insert(estadoServicio);
  }

  for (var map in data['IndicadorServicio'] ?? []) {
    final indicadorServicio = IndicadorServicio(
      id: map['id'] as int,
      idIndicador: map['idIndicador'] as int,
      idServicio: map['idServicio'] as int,
      idTecnico: map['idTecnico'] as int,
      valor: map['valor'] as String,
    );
    await indicadorServicioProvider.insert(indicadorServicio);
  }

  for (var map in data['IndirectoServicio'] ?? []) {
    final indirectoServicio = IndirectoServicio(
      id: map['id'] as int,
      idIndirecto: map['idIndirecto'] as int,
      idServicio: map['idServicio'] as int,
      cantidad: map['cantidad'] as int,
      costo: map['costo'] as int,
      valor: map['valor'] as int,
    );
    await indirectoServicioProvider.insert(indirectoServicio);
  }

  for (var map in data['ItemActividadServicio'] ?? []) {
    final itemActividadServicio = ItemActividadServicio(
      id: map['id'] as int,
      idItem: map['idItem'] as int,
      idActividadServicio: map['idActividadServicio'] as int,
      cantidadReq: map['cantidadReq'] as double,
    );
    await itemActividadServicioProvider.insert(itemActividadServicio);
  }

  for (var map in data['ItemServicio'] ?? []) {
    final itemServicio = ItemServicio(
      id: map['id'] as int,
      idItem: map['idItem'] as int,
      idServicio: map['idServicio'] as int,
      cantidad: map['cantidad'] as double,
      costo: map['costo'] as int,
      valor: map['valor'] as int,
      cantidadReq: map['cantidadReq'] as double,
      fechaUltimaVez: map['fechaUltimaVez'] as String,
      vidaUtil: map['vidaUtil'] as String,
    );
    await itemServicioProvider.insert(itemServicio);
  }

  for (var map in data['NovedadServicio'] ?? []) {
    final novedadServicio = NovedadServicio(
      id: map['id'] as int,
      idServicio: map['idServicio'] as int,
      idNovedad: map['idNovedad'] as int,
    );
    await novedadServicioProvider.insert(novedadServicio);
  }

  for (var map in data['Servicio'] ?? []) {
    final servicio = Servicio(
      id: map['id'] as int,
      idTecnico: map['idTecnico'] as int,
      idCliente: map['idCliente'] as int,
      idEstadoServicio: map['idEstadoServicio'] as int,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      direccion: map['direccion'] as String,
      idCiudad: map['idCiudad'] as int,
      latitud: (map['latitud'] is int)
          ? (map['latitud'] as int).toDouble()
          : map['latitud'] as double,
      longitud: (map['longitud'] is int)
          ? (map['longitud'] as int).toDouble()
          : map['longitud'] as double,
      fechaInicio: map['fechaInicio'] as String,
      fechayhorainicio: map['fechayhorainicio'] as String,
      fechaModificacion: map['fechaModificacion'] as String,
      fechaFin: map['fechaFin'] as String,
      idEquipo: map['idEquipo'] as int,
      idFalla: map['idFalla'] as int,
      observacionReporte: map['observacionReporte'] as String,
      radicado: map['radicado'] as String,
      idTipoServicio: map['idTipoServicio'] as int,
      cedulaFirma: map['cedulaFirma'] as String,
      nombreFirma: map['nombreFirma'] as String,
      archivoFirma: map['archivoFirma'] as String,
      orden: map['orden'] as int,
      fechaLlegada: map['fechaLlegada'] as String,
      comentarios: map['comentarios'] as String,
      consecutivo: map['consecutivo'] as int,
    );
    await servicioProvider.insert(servicio);
  }

  for (var map in data['TipoServicio'] ?? []) {
    final tipoServicio = TipoServicio(
      id: map['id'] as int,
      descripcion: map['descripcion'] as String,
    );
    await tipoServicioProvider.insert(tipoServicio);
  }

  return true;
}

Future<void> insertMasterFileInSqflite(
    ArchiveFile file, Database database) async {
  dynamic createProvider(String fileName) {
    switch (fileName) {
      case "Actividad.txt":
        return ActividadProvider(db: database);
      case "ActividadModelo.txt":
        return ActividadModeloProvider(db: database);
      case "CategoriaIndicador.txt":
        return CategoriaIndicadorProvider(db: database);
      case "Ciudad.txt":
        return CiudadProvider(db: database);
      case "Cliente.txt":
        return ClienteProvider(db: database);
      case "Diagnostico.txt":
        return DiagnosticoProvider(db: database);
      case "Equipo.txt":
        return EquipoProvider(db: database);
      case "EstadoServicio.txt":
        return EstadoServicioProvider(db: database);
      case "Falla.txt":
        return FallaProvider(db: database);
      case "Indicador.txt":
        return IndicadorProvider(db: database);
      case "IndicadorModelo.txt":
        return IndicadorModeloProvider(db: database);
      case "Indirecto.txt":
        return IndirectoProvider(db: database);
      case "Item.txt":
        return ItemProvider(db: database);
      case "ItemModelo.txt":
        return ItemModeloProvider(db: database);
      case "Modelo.txt":
        return ModeloProvider(db: database);
      case "Novedad.txt":
        return NovedadProvider(db: database);
      case "RegistroCamposAdicionales.txt":
        return RegistroCamposAdicionalesProvider(db: database);
      case "TipoCliente.txt":
        return TipoClienteProvider(db: database);
      case "TipoItem.txt":
        return TipoItemProvider(db: database);
      case "TipoServicio.txt":
        return TipoServicioProvider(db: database);
      default:
        return null;
    }
  }

  final provider = createProvider(file.name);
  if (provider != null) {
    await provider.insertInitFile(file);
  }
}

Future<bool> Authentication(String user, String pass) async {
  Database database = await DatabaseMain(path: localDatabasePath).onCreate();
  List<Tecnico> tecnicos = await TecnicoProvider(db: database).getAll();
  Tecnico tecnico = tecnicos[0];
  if (user == tecnico.usuario && pass == tecnico.clave) {
    return true;
  }
  return false;
}

Map<String, List<Map<String, dynamic>>> responseXMLtoJSON(String xmlString) {
  final document = XmlDocument.parse(xmlString);

  final Map<String, List<Map<String, dynamic>>> result = {
    'Tecnico': [],
    'Cliente': [],
    'Equipo': [],
    'Servicio': [],
  };

  for (var stageMessage in document.findAllElements('StageMessage')) {
    final body = stageMessage.findElements('Mensaje').single.innerText;
    final model = stageMessage.findElements('FamiliaMensaje').single.innerText;
    final map = jsonDecode(body);

    switch (model) {
      case "Tecnico":
        result['Tecnico']?.add({
          "id": int.parse(map['id']),
          "cedula": map['cedula'] ?? "",
          "nombre": map['nombre'] ?? "",
          "idProveedor": int.parse(map['idProveedor']),
          "idEstadoTecnico": int.parse(map['idEstadoTecnico']),
          "usuario": map['usuario'] ?? "",
          "clave": map['clave'] ?? "",
          "telefono": map['telefono'] ?? "",
          "celular": map['celular'] ?? "",
          "latitud": double.parse(map['latitud']),
          "longitud": double.parse(map['longitud']),
          "androidID": map['androidID'] ?? "",
          "fechaPulso": map['fechaPulso'] ?? "",
          "versionApp": map['versionApp'] ?? "",
        });
        break;
      case "Cliente":
        result['Cliente']?.add({
          "id": int.parse(map['id']),
          "nombre": map['nombre'] ?? "",
          "direccion": map['direccion'] ?? "",
          "idCiudad": int.parse(map['idCiudad']),
          "telefono": map['telefono'] ?? "",
          "celular": map['celular'] ?? "",
          "idTipoCliente": int.parse(map['idTipoCliente']),
          "idTipoDocumento": map['idTipoDocumento'] ?? "",
          "numDocumento": map['numDocumento'] ?? "",
          "establecimiento": map['establecimiento'] ?? "",
          "contacto": map['contacto'] ?? "",
          "idEstado": int.parse(map['idEstado']),
          "correo": map['correo'] ?? "",
        });
        break;
      case "Equipo":
        result['Equipo']?.add({
          "id": int.parse(map['id']),
          "serial": map['serial'] ?? "",
          "nombre": map['nombre'] ?? "",
          "fechaCompra": map['fechaCompra'] ?? "",
          "fechaGarantia": map['fechaGarantia'] ?? "",
          "idModelo": int.parse(map['idModelo']),
          "idEstadoEquipo": int.parse(map['idEstadoEquipo']),
          "idProveedor": int.parse(map['idProveedor']),
          "idCliente": int.parse(map['idCliente']),
        });
        break;
      case "Servicio":
        result['Servicio']?.add({
          "id": int.parse(map['id']),
          "idTecnico": int.parse(map['idTecnico']),
          "idCliente": int.parse(map['idCliente']),
          "idEstadoServicio": int.parse(map['idEstadoServicio']),
          "nombre": map['nombre'] ?? "",
          "descripcion": map['descripcion'] ?? "",
          "direccion": map['direccion'] ?? "",
          "idCiudad": int.parse(map['idCiudad']),
          "latitud": (map['latitud'] is int)
              ? (int.parse(map['latitud'])).toDouble()
              : double.parse(map['latitud']),
          "longitud": (map['longitud'] is int)
              ? (int.parse(map['longitud'])).toDouble()
              : double.parse(map['longitud']),
          "fechaInicio": map['fechaInicio'] ?? "",
          "fechayhorainicio": map['fechayhorainicio'] ?? "",
          "fechaModificacion": map['fechaModificacion'] ?? "",
          "fechaFin": map['fechaFin'] ?? "",
          "idEquipo": int.parse(map['idEquipo']),
          "idFalla": int.parse(map['idFalla']),
          "observacionReporte": map['observacionReporte'] ?? "",
          "radicado": map['radicado'] ?? "",
          "idTipoServicio": int.parse(map['idTipoServicio']),
          "cedulaFirma": map['cedulaFirma'] ?? "",
          "nombreFirma": map['nombreFirma'] ?? "",
          "archivoFirma": map['archivoFirma'] ?? "",
          "orden": int.parse(map['orden']),
          "fechaLlegada": map['fechaLlegada'] ?? "",
          "comentarios": map['comentarios'] ?? "",
          "consecutivo": int.parse(map['consecutivo']),
        });
        break;
      case "Maletin":
        result['Maletin']?.add({
          "id": int.parse(map['id']),
          "idItem": int.parse(map['idItem']),
          "idTecnico": int.parse(map['idTecnico']),
          "cantidad": double.parse(map['cantidad']),
          "costo": double.parse(map['costo']),
          "valor": double.parse(map['valor'])
        });
        break;
      case "Modelo":
        result['Modelo']?.add({
          "id": int.parse(map['id']),
          "descripcion": map['descripcion'] ?? "",
        });
        break;
      case "Falla":
        result['Falla']?.add({
          "id": int.parse(map['id']),
          "descripcion": map['descripcion'] ?? "",
          "estado": int.parse(map['estado']),
        });
        break;
      case "Item":
        result['Item']?.add({
          "id": int.parse(map['id']),
          "SKU": map['SKU'] ?? "",
          "descripcion": map['descripcion'] ?? "",
          "tipo": int.parse(map['tipo']),
          "costo": int.parse(map['costo']),
          "precio": int.parse(map['precio']),
          "idEstadoItem": int.parse(map['idEstadoItem']),
          "foto": map['foto'] ?? "",
        });
        break;
      case "Novedad":
        result['Novedad']?.add({
          "id": int.parse(map['id']),
          "descripcion": map['descripcion'] ?? "",
          "estado": int.parse(map['estado']),
        });
        break;
      case "NovedadServicio":
        result['NovedadServicio']?.add({
          "id": int.parse(map['id']),
          "idServicio": int.parse(map['idServicio']),
          "idNovedad": int.parse(map['idNovedad']),
        });
        break;
      case "ActividadServicio":
        result['ActividadServicio']?.add({
          "id": int.parse(map['id']),
          "idActividad": int.parse(map['idActividad']),
          "idServicio": int.parse(map['idServicio']),
          "cantidad": int.parse(map['cantidad']),
          "costo": int.parse(map['costo']),
          "valor": int.parse(map['valor']),
          "ejecutada": int.parse(map['ejecutada']),
        });
        break;
      case "AdjuntoServicio":
        result['AdjuntoServicio']?.add({
          "id": int.parse(map['id']),
          "idServicio": int.parse(map['idServicio']),
          "idTecnico": int.parse(map['idTecnico']),
          "titulo": map['titulo'] ?? "",
          "descripcion": map['descripcion'] ?? "",
          "tipo": map['tipo'] ?? "",
        });
        break;
      case "DiagnosticoServicio":
        result['DiagnosticoServicio']?.add({
          "id": int.parse(map['id']),
          "idServicio": int.parse(map['idServicio']),
          "idDiagnostico": int.parse(map['idDiagnostico']),
        });
        break;
      case "IndicadorServicio":
        result['IndicadorServicio']?.add({
          "id": int.parse(map['id']),
          "idIndicador": int.parse(map['idIndicador']),
          "idServicio": int.parse(map['idServicio']),
          "idTecnico": int.parse(map['idTecnico']),
          "valor": map['valor'] as String,
        });
        break;
      case "IndirectoServicio":
        result['IndirectoServicio']?.add({
          "id": int.parse(map['id']),
          "idIndirecto": int.parse(map['idIndirecto']),
          "idServicio": int.parse(map['idServicio']),
          "cantidad": int.parse(map['cantidad']),
          "costo": int.parse(map['costo']),
          "valor": int.parse(map['valor']),
        });
        break;
      case "ItemServicio":
        result['ItemServicio']?.add({
          "id": int.parse(map['id']),
          "idItem": int.parse(map['idItem']),
          "idServicio": int.parse(map['idServicio']),
          "cantidad": int.parse(map['cantidad']),
          "costo": int.parse(map['costo']),
          "valor": int.parse(map['valor']),
          "cantidadReq": double.parse(map['cantidadReq']),
          "fechaUltimaVez": map['fechaUltimaVez'] ?? "",
          "vidaUtil": map['vidaUtil'] ?? "",
        });
        break;
    }
  }

  return result;
}
