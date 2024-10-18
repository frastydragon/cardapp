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
     body: SingleChildScrollView( // <-- Wrap in SingleChildScrollView
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.queryCardsByFolder(widget.folderId),
        builder: (context, snapshot) {
         if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cards available.'));
          }

          final cards = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true, // <-- Add this to make GridView take only the required height
            physics: const NeverScrollableScrollPhysics(), // <-- Disable scrolling on GridView
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
                  _showCardDetails(card);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(card[DatabaseHelper.columnImageUrl]),
                      Text(card[DatabaseHelper.columnCardName]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addCard(),
      child: const Icon(Icons.add),
      
    ),
    
  );
}

  Future<void> _addCard() async {
    final cardCount = await dbHelper.getCardCountInFolder(widget.folderId);
    if (cardCount >= 20) {
      _showErrorDialog('This folder can only hold 6 cards.');
      return;
    }

    // Example card to add
    Map<String, dynamic> card = {
      'name': 'Ace of Spades',
      'suit': 'spades',
      'image_url':'assets/ace_of_spades.png',
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