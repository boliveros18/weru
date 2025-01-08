import 'package:sqflite/sqflite.dart';
import '../models/novedadservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class NovedadServicioProvider {
  final Database db;
  NovedadServicioProvider({required this.db});

  Future<void> insert(NovedadServicio novedadservicio) async {
    await db.insert(
      'NovedadServicio',
      novedadservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NovedadServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('NovedadServicio');
    return maps.map((map) {
      return NovedadServicio(
        id: map['id'] as int,
        idServicio: map['idServicio'] as int,
        idNovedad: map['idNovedad'] as int,
      );
    }).toList();
  }

  Future<void> update(NovedadServicio novedadservicio) async {
    await db.update(
      'NovedadServicio',
      novedadservicio.toMap(),
      where: 'id = ?',
      whereArgs: [novedadservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'NovedadServicio',
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
      NovedadServicio novedadservicio = NovedadServicio(
        id: int.parse(parts[0].trim()),
        idServicio: int.parse(parts[1].trim()),
        idNovedad: int.parse(parts[2].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'NovedadServicio',
          novedadservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
