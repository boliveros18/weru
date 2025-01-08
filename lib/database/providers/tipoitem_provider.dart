import 'package:sqflite/sqflite.dart';
import '../models/tipoitem.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class TipoItemProvider {
  final Database db;
  TipoItemProvider({required this.db});

  Future<void> insert(TipoItem tipoitem) async {
    await db.insert(
      'TipoItem',
      tipoitem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TipoItem>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('TipoItem');
    return maps.map((map) {
      return TipoItem(
        id: map['id'] as int,
        descripcion: map['descripcion'] as String,
      );
    }).toList();
  }

  Future<void> update(TipoItem tipoitem) async {
    await db.update(
      'TipoItem',
      tipoitem.toMap(),
      where: 'id = ?',
      whereArgs: [tipoitem.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'TipoItem',
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
      TipoItem tipoitem = TipoItem(
        id: int.parse(parts[0].trim()),
        descripcion: parts[1].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'TipoItem',
          tipoitem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
