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
        $columnFolderName TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCards (
        $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnFolderIdForeign INTEGER NOT NULL,
        FOREIGN KEY ($columnFolderIdForeign) REFERENCES $tableFolders ($columnFolderId)
      )
    ''');

    // Prepopulate folders and cards
    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    List<Map<String, dynamic>> suits = [
      {'name': 'Hearts'},
      {'name': 'Spades'},
      {'name': 'Diamonds'},
      {'name': 'Clubs'},
    ];

    for (var suit in suits) {
      await db.insert(tableFolders, {
        columnFolderName: suit['name'],
        columnTimestamp: DateTime.now().toString(),
      });
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    List<Map<String, dynamic>> suits = [
      {'name': 'Hearts', 'folderId': 1},
      {'name': 'Spades', 'folderId': 2},
      {'name': 'Diamonds', 'folderId': 3},
      {'name': 'Clubs', 'folderId': 4},
    ];

    List<String> cardNames = [
      'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
    ];

    for (var suit in suits) {
      for (var cardName in cardNames) {
        String cardImageName = '$cardName${suit['name'].substring(0, 1)}.png';
        String imageUrl = 'https://example.com/$cardImageName';
        
        await db.insert(tableCards, {
          columnCardName: cardName,
          columnSuit: suit['name'],
          columnImageUrl: imageUrl,
          columnFolderIdForeign: suit['folderId'],
        });
      }
    }
  }

  // Insert a new card
  Future<int> insertCard(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(tableCards, row);
  }

  // Query all cards in a folder
  Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
    Database? db = await instance.database;
    return await db!.query(
      tableCards,
      where: '$columnFolderIdForeign = ?',
      whereArgs: [folderId],
    );
  }

  // Delete a card
  Future<int> deleteCard(int id) async {
    Database? db = await instance.database;
    return await db!.delete(
      tableCards,
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
    final result = await db!.rawQuery(
      'SELECT COUNT(*) FROM $tableCards WHERE $columnFolderIdForeign = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
