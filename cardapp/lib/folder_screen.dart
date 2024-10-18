// folder_screen.dart
import 'package:flutter/material.dart';
import 'databasehelper.dart';
import 'card_screen.dart';

class FolderScreen extends StatefulWidget {
  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.queryFolders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final folders = snapshot.data!;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder[DatabaseHelper.columnFolderName]),
                onTap: () {
                  // Navigate to card screen for the selected folder
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardScreen(folderId: folder[DatabaseHelper.columnFolderId]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

    );
  }

}