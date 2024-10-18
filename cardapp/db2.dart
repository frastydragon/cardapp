import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static const _databaseName = "CardApp.db";
  static const _databaseVersion = 1;

  // Tables
  static const folder = 'folders';
  static const cards = 'cards';

  // Columns for the folder table
  static const folderId = 'id';
  static const columnSuit = 'suit';
  static const folderName = 'folderName';

  // Columns for the cards table
  static const cardId = 'id';
  static const columnNum = 'num';
  static const name = 'name';
  static const columnImageUrl = 'image_url'; // Column for storing image asset paths
  static const foreignId = 'folderKey';

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $folder (
        $folderId INTEGER PRIMARY KEY,
        $columnSuit TEXT NOT NULL,
        $folderName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cards (
        $cardId INTEGER PRIMARY KEY,
        $columnNum INTEGER NOT NULL,
        $name TEXT NOT NULL,
        $foreignId INTEGER,
        $columnImageUrl TEXT, // New column for image asset path
        FOREIGN KEY ($foreignId) REFERENCES $folder ($folderId)
      )
    ''');
  }

  // Insert a new folder
  Future<int> insertFolder(Map<String, dynamic> row) async {
    return await _db.insert(folder, row);
  }

  // Query all rows from folder
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(folder);
  }

  // Query row count from folder
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $folder');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // Update folder
  Future<int> updateFolder(Map<String, dynamic> row) async {
    int id = row[folderId];
    return await _db.update(
      folder,
      row,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  // Delete folder
  Future<int> deleteFolder(int id) async {
    return await _db.delete(
      folder,
      where: '$folderId = ?',
      whereArgs: [id],
    );
  }

  // Insert a new card
  Future<int> insertCard(Map<String, dynamic> row) async {
    return await _db.insert(cards, row);
  }

  // Query all rows from cards
  Future<List<Map<String, dynamic>>> queryAllRowsC() async {
    return await _db.query(cards);
  }

  // Query row count from cards
  Future<int> queryRowCountC() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $cards');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // Update card
  Future<int> updateCard(Map<String, dynamic> row) async {
    int id = row[cardId];
    return await _db.update(
      cards,
      row,
      where: '$cardId = ?',
      whereArgs: [id],
    );
  }

  // Delete card
  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cards,
      where: '$cardId = ?',
      whereArgs: [id],
    );
  }
  Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
  return await _db.query(cards, where: '$foreignId = ?', whereArgs: [folderId]);
}

}