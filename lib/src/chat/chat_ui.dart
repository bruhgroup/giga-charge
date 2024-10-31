import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user; // Add a parameter for the selected user

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  // Initial dialogue options
  List<String> _currentDialogueOptions = ['Hello! Can we swap?', 'Sure!', 'No, I am busy now!'];

  // Dialogue flow based on responses
  final Map<String, List<String>> _dialogueFlows = {
    'Hello! Can we swap?': ['Sure!', 'No, I am busy now!'],
    'Sure!': ['Give me 5 minutes', 'Give me 15 minutes', 'Give me 25 minutes'],
    'No, I am busy now!': ['Sorry!'],
    'Give me 5 minutes': ['Thanks!'],
    'Give me 15 minutes': ['Thanks!'],
    'Give me 25 minutes': ['Thanks!'],
    'Thanks!': [],
  };

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(isLoading: true);

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index = _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage = (_messages[index] as types.FileMessage).copyWith(isLoading: null);

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handleSendMessage(String text) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _addMessage(textMessage);

    // Update the dialogue options based on the message sent
    setState(() {
      _currentDialogueOptions = _dialogueFlows[text] ?? [];
    });
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Chat with ${widget.user['first_name']}'), // Display selected user name
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Navigates back to the previous page (room select)
        },
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: Chat(
            messages: _messages,
            onMessageTap: _handleMessageTap,
            user: _user,
            showUserAvatars: true,
            showUserNames: true,
            onSendPressed: _handleSendPressed,
          ),
        ),
        _buildDialogueOptions(), // Dialogue options at the bottom
      ],
    ),
  );

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Update dialogue options based on the message sent
    setState(() {
      _currentDialogueOptions = _dialogueFlows[message.text] ?? [];
    });
  }

  Widget _buildDialogueOptions() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _currentDialogueOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => _handleSendMessage(option),
              child: Text(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
