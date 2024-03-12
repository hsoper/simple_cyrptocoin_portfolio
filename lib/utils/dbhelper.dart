import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// this File is a modification of the 05_persistence/db_helper.dart example file
// DBHelper is a Singleton class (only one instance)
class DBHelper {
  static const String _databaseName = 'coins.db';
  static const int _databaseVersion = 1;

  DBHelper._(); // private constructor (can't be called from outside)

  // the single instance
  static final DBHelper _singleton = DBHelper._();

  // factory constructor that always returns the single instance
  factory DBHelper() => _singleton;

  // the singleton will hold a reference to the database once opened
  Database? _database;

  // initialize the database when it's first requested
  get db async {
    _database ??= await _initDatabase(); // if null, initialize it
    return _database;
  }

  Future<Database> _initDatabase() async {
    // use path_provider to get the platform-dependent documents directory
    var dbDir = await getApplicationDocumentsDirectory();

    // path.join joins two paths together, and is platform aware
    var dbPath = path.join(dbDir.path, _databaseName);

    // for debugging
    //await deleteDatabase(dbPath);

    // open the database
    var db = await openDatabase(dbPath,
        version: _databaseVersion, // used for migrations

        // called when the database is first created
        onCreate: (Database db, int version) async {
      // create the userTotals table
      await db.execute('''
          CREATE TABLE user_totals(
            coin_id TEXT PRIMARY KEY,
            total REAL,
            price REAL,
            coin_name TEXT,
            image_url TEXT
          )
        ''');
    });

    return db;
  }

  // fetch records from a table with an optional "where" clause
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table) : db.query(table, where: where);
  }

  // insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // update a record in a table
  Future<void> update(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'coin_id = ?',
      whereArgs: [data['coin_id']],
    );
  }

  // delete a record from a table
  Future<void> delete(String table, String id) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'coin_id = ?',
      whereArgs: [id],
    );
  }
}
