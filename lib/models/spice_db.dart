import 'package:allspice_mobile/models/spice.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SpiceDB {
  static final SpiceDB instance = SpiceDB._init();

  static Database? _database;

  SpiceDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('spices.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'BOOLEAN NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final strType = 'VARCHAR(25) NOT NULL';

    await db.execute('''
    CREATE TABLE $tableSpices (
    ${SpiceFields.id} $idType,
    ${SpiceFields.container} $intType,
    ${SpiceFields.name} $strType,
    ${SpiceFields.favorite} $boolType
    )
    ''');
  }

  Future<Spice> create(Spice spice) async {
    final db = await instance.database;
    final id = await db.insert(tableSpices, spice.toJson());
    return spice.copy(id: id);
  }

  Future<Spice> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSpices,
      columns: SpiceFields.values,
      where: '${SpiceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Spice.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Spice>> readAll() async {
    final db = await instance.database;
    final orderBy =
        '${SpiceFields.favorite} DESC, ${SpiceFields.name} COLLATE NOCASE ASC';
    final result = await db.query(tableSpices, orderBy: orderBy);
    return result.map((json) => Spice.fromJson(json)).toList();
  }

  Future<List> readContainers() async {
    final db = await instance.database;
    final result = await db.query(
      tableSpices,
      columns: [SpiceFields.container],
    );

    if (result.isNotEmpty) {
      return result.map((e) => e['${SpiceFields.container}']).toList();
    } else {
      return [];
    }
  }

  Future<int> update(Spice spice) async {
    final db = await instance.database;

    return db.update(
      tableSpices,
      spice.toJson(),
      where: '${SpiceFields.id} = ?',
      whereArgs: [spice.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableSpices,
      where: '${SpiceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
