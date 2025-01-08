import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
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
    if (file.name == "Indicador.txt") {
      print(await provider.getAll());
    }
  }
}
