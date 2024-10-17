import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final _databaseName = "CardApp.db";
  static final _databaseVersion = 1;

  static final tableFolders = 'folders';
  static final tableCards = 'cards';

  static final columnFolderId = 'id';
  static final columnFolderName = 'name';
  static final columnTimestamp = 'timestamp';

  static final columnCardId = 'id';
  static final columnCardName = 'name';
  static final columnSuit = 'suit';
  static final columnImageUrl = 'image_url';
  static final columnFolderIdForeign = 'folder_id';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFolders (
        $columnFolderId INTEGER PRIMARY KEY,
        $columnFolderName TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCards (
        $columnCardId INTEGER PRIMARY KEY,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnFolderIdForeign INTEGER NOT NULL,
        FOREIGN KEY ($columnFolderIdForeign) REFERENCES $tableFolders ($columnFolderId)
      )
    ''');

    // Prepopulate Folders
    await db.insert(tableFolders, {columnFolderName: 'Hearts', columnTimestamp: DateTime.now().toString()});
    await db.insert(tableFolders, {columnFolderName: 'Spades', columnTimestamp: DateTime.now().toString()});
    await db.insert(tableFolders, {columnFolderName: 'Diamonds', columnTimestamp: DateTime.now().toString()});
    await db.insert(tableFolders, {columnFolderName: 'Clubs', columnTimestamp: DateTime.now().toString()});
  }

  // Insert new card
Future<int> insertCard(Map<String, dynamic> row) async {
  Database? db = await instance.database;
  return await db!.insert(tableCards, row);
}

// Query all cards in a folder
Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
  Database? db = await instance.database;
  return await db!.query(tableCards, where: '$columnFolderIdForeign = ?', whereArgs: [folderId]);
}

// Delete card
Future<int> deleteCard(int id) async {
  Database? db = await instance.database;
  return await db!.delete(tableCards, where: '$columnCardId = ?', whereArgs: [id]);
}
}