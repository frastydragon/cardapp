// card_screen.dart
import 'package:flutter/material.dart';
import 'databasehelper.dart';

class CardScreen extends StatefulWidget {
  final int folderId;
  const CardScreen({super.key, required this.folderId});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
   final dbHelper = DatabaseHelper.instance; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.queryCardsByFolder(widget.folderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return GestureDetector(
                onTap: () {
                  // Handle card tap (e.g., show details or edit)
                  _showCardDetails(card);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(card[DatabaseHelper.columnImageUrl]),
                      Text(card['name']),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCard(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCard() async {
    final cardCount = await dbHelper.getCardCountInFolder(widget.folderId);
    if (cardCount >= 6) {
      _showErrorDialog('This folder can only hold 6 cards.');
      return;
    }

    // Example card to add
    Map<String, dynamic> card = {
      'name': 'Ace of Spades',
      'image_url': '',
      'folder_id': widget.folderId,
    };

    await dbHelper.insertCard(card);
    setState(() {
      // Update UI after card is added
    });
  }

  Future<void> _showErrorDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCardDetails(Map<String, dynamic> card) {
    // Implement card details display or editing here
  }
}