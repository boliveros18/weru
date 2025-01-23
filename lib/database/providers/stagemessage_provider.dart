import 'package:sqflite/sqflite.dart';
import '../models/stagemessage.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

class StageMessageProvider {
  final Database db;
  StageMessageProvider({required this.db});

  Future<void> insert(StageMessage stagemessage) async {
    await db.insert(
      'StageMessage',
      stagemessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StageMessage> getItemById(int id) async {
    final List<Map<String, dynamic>> items = await db.query(
      'StageMessage',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (items.isEmpty) {
      throw Exception('Item de StageMessage no encontrado!');
    }
    return StageMessage.fromMap(items.first);
  }

  Future<List<StageMessage>> getAll() async {
    final List<Map<String, Object?>> maps = await db.query('StageMessage');
    return maps.map((map) {
      return StageMessage(
        id: map['id'] as int,
        Message: map['Message'] as String,
        MessageFamily: map['MessageFamily'] as String,
        Address: map['Address'] as String,
        Action: map['Action'] as String,
        RetryCount: map['RetryCount'] as int,
        Created: map['Created'] as DateTime,
        Updated: map['Updated'] as DateTime,
        Proccesed: map['Proccesed'] as int,
        ErrorDescription: map['ErrorDescription'] as String,
        Error: map['Error'] as int,
        BusinessId: map['BusinessId'] as String,
      );
    }).toList();
  }

  Future<void> update(StageMessage stagemessage) async {
    await db.update(
      'StageMessage',
      stagemessage.toMap(),
      where: 'id = ?',
      whereArgs: [stagemessage.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'StageMessage',
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
      StageMessage stagemessage = StageMessage(
        id: int.parse(parts[0].trim()),
        Message: parts[1].trim(),
        MessageFamily: parts[2].trim(),
        Address: parts[3].trim(),
        Action: parts[4].trim(),
        RetryCount: int.parse(parts[5].trim()),
        Created: DateTime.parse(parts[6].trim()),
        Updated: DateTime.parse(parts[7].trim()),
        Proccesed: int.parse(parts[8].trim()),
        ErrorDescription: parts[9].trim(),
        Error: int.parse(parts[10].trim()),
        BusinessId: parts[11].trim(),
      );
      await db.transaction((database) async {
        await database.insert(
          'StageMessage',
          stagemessage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    }
  }
}
