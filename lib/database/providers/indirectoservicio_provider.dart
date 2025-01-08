import 'package:sqflite/sqflite.dart';
import '../models/indirectoservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class IndirectoServicioProvider {

  final Database db;
  IndirectoServicioProvider({required this.db});

  Future<void> insert(IndirectoServicio indirectoservicio) async {
    await db.insert(
      'IndirectoServicio',
      indirectoservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<IndirectoServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('IndirectoServicio');
    return maps.map((map) {
      return IndirectoServicio(
        id: map['id'] as int,
        idIndirecto: map['idIndirecto'] as int,
        idServicio: map['idServicio'] as String,
        cantidad: map['cantidad'] as int,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
      );
    }).toList();
  }

  Future<void> update(IndirectoServicio indirectoservicio) async {
    await db.update(
      'IndirectoServicio',
      indirectoservicio.toMap(),
      where: 'id = ?',
      whereArgs: [indirectoservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'IndirectoServicio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

Future<void> insertInitFile(ArchiveFile file) async {
  List<int> bytes = file.content;
  String fileContent = utf8.decode(bytes);
  List<String> lines = fileContent.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      List<String> parts = line.split('|');
      IndirectoServicio indirectoservicio = IndirectoServicio(
          id: int.parse(parts[0].trim()),
idIndirecto: int.parse(parts[1].trim()),
idServicio: parts[2].trim(),
cantidad: int.parse(parts[3].trim()),
costo: int.parse(parts[4].trim()),
valor: int.parse(parts[5].trim()),
        );
      await db.transaction((database) async {
        await database.insert(
          'IndirectoServicio',
          indirectoservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
