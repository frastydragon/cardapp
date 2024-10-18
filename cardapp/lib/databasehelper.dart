import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static const _databaseName = "CardApp.db";
  static const _databaseVersion = 1;

  static const tableFolders = 'folders';
  static const cards = 'cards';

  static const columnFolderId = 'id';
  static const columnFolderName = 'name';

  static const columnCardId = 'id';
  static const columnCardName = 'name';
  static const columnSuit = 'suit';
  static const columnImageUrl = 'image_url';
  static const columnFolderIdForeign = 'folder_id';

  DatabaseHelper._privateConstructor();
  static DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $tableFolders (
        $columnFolderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFolderName TEXT NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE $cards (
        $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnFolderIdForeign INTEGER NOT NULL,
        FOREIGN KEY ($columnFolderIdForeign) REFERENCES $tableFolders ($columnFolderId)
      )
    ''');
  }

  // Insert a new card
  Future<int> insertCard(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(cards, row);
  }

  // Query all cards in a folder
  Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
    Database? db = await instance.database;
    return await db!.query(
      cards,
      where: '$columnFolderIdForeign = ?',
      whereArgs: [folderId],
    );
  }

  // Delete a card
  Future<int> deleteCard(int id) async {
    Database? db = await instance.database;
    return await db!.delete(
      cards,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }

  // Query all folders
  Future<List<Map<String, dynamic>>> queryFolders() async {
    Database? db = await instance.database;
    return await db!.query(tableFolders);
  }

  // Get the count of cards in a folder
  Future<int> getCardCountInFolder(int folderId) async {
    Database? db = await instance.database;
    var result = await db!.rawQuery(
      'SELECT COUNT(*) FROM $cards WHERE $columnFolderIdForeign = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

