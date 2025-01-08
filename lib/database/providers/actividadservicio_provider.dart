import 'package:sqflite/sqflite.dart';
import '../models/actividadservicio.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class ActividadServicioProvider {
  final Database db;
  ActividadServicioProvider({required this.db});

  Future<void> insert(ActividadServicio actividadservicio) async {
    await db.insert(
      'ActividadServicio',
      actividadservicio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActividadServicio>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('ActividadServicio');
    return maps.map((map) {
      return ActividadServicio(
        id: map['id'] as int,
        idActividad: map['idActividad'] as int,
        idServicio: map['idServicio'] as String,
        cantidad: map['cantidad'] as int,
        costo: map['costo'] as int,
        valor: map['valor'] as int,
        ejecutada: map['ejecutada'] as int,
      );
    }).toList();
  }

  Future<void> update(ActividadServicio actividadservicio) async {
    await db.update(
      'ActividadServicio',
      actividadservicio.toMap(),
      where: 'id = ?',
      whereArgs: [actividadservicio.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'ActividadServicio',
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
      ActividadServicio actividadservicio = ActividadServicio(
        id: int.parse(parts[0].trim()),
        idActividad: int.parse(parts[1].trim()),
        idServicio: parts[2].trim(),
        cantidad: int.parse(parts[3].trim()),
        costo: int.parse(parts[4].trim()),
        valor: int.parse(parts[5].trim()),
        ejecutada: int.parse(parts[6].trim()),
      );
      await db.transaction((database) async {
        await database.insert(
          'ActividadServicio',
          actividadservicio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
