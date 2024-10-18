import 'package:flutter/material.dart';
import 'folder_screen.dart';
import 'card_screen.dart';
import 'databasehelper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folder and Card Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderScreen(), // Set FolderScreen as the home screen
      onGenerateRoute: (settings) {
        if (settings.name == '/cards') {
          final int folderId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => CardScreen(folderId: folderId),
          );
        }
        return null;
      },
    );
  }
}