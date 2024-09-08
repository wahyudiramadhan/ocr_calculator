// TODO Implement this library.import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "results.db";
  static final _databaseVersion = 1;

  static final table = 'Results';

  static final columnId = 'id';
  static final columnRawText = 'rawText';
  static final columnExpression = 'expression';
  static final columnResult = 'result';
  static final columnImagePath = 'imagePath';

  // Singleton instance
  static Database? _database;

  // Private constructor to ensure single instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Function to get the database, initializing it if necessary
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize and create the database
  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnRawText TEXT NOT NULL,
        $columnExpression TEXT NOT NULL,
        $columnResult TEXT NOT NULL,
        $columnImagePath TEXT NOT NULL
      )
    ''');
  }

  // CRUD methods (optional, can be adjusted based on your needs)

  // Insert a record into the database
  static Future<int> insert(Map<String, dynamic> row) async {
    Database db = await getDatabase();
    return await db.insert(table, row);
  }

  // Query all records from the database
  static Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await getDatabase();
    return await db.query(table);
  }

  // Update a record in the database
  static Future<int> update(Map<String, dynamic> row) async {
    Database db = await getDatabase();
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a record from the database
  static Future<int> delete(int id) async {
    Database db = await getDatabase();
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
