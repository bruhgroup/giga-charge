import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'chat_ui.dart'; // Import your chat UI file

class RoomSelectionPage extends StatefulWidget {
  const RoomSelectionPage({super.key});

  @override
  _RoomSelectionPageState createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final String response = await rootBundle.loadString('assets/fakeData.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _users = List<Map<String, dynamic>>.from(data);
    });
  }

  void _navigateToChat(Map<String, dynamic> user, String index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(user: user, roomId: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text('${user['first_name']} ${user['last_name']}'),
            onTap: () => _navigateToChat(user, index.toString()),
          );
        },
      ),
    );
  }
}
