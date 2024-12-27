import 'package:sqflite/sqflite.dart';
import '../models/credentials.dart';
import 'package:path/path.dart';

class CredentialsProvider {
  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    print('Database path: $dbPath');
    return openDatabase(
      join(await getDatabasesPath(), 'weru.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE credentials(id INTEGER PRIMARY KEY, name TEXT, value TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insert(Credentials credential) async {
    final db = await database;
    await db.insert(
      'credentials',
      credential.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Credentials>> getCredentials() async {
    final db = await database;

    final List<Map<String, Object?>> credentialMaps =
        await db.query('credentials');
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'value': value as String,
          } in credentialMaps)
        Credentials(id: id, name: name, value: value),
    ];
  }

  Future<void> update(Credentials credential) async {
    final db = await database;

    await db.update(
      'credentials',
      credential.toMap(),
      where: 'id = ?',
      whereArgs: [credential.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(
      'credentials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
