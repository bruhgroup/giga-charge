import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String roomId; // Unique identifier for each room

  const ChatPage({super.key, required this.user, required this.roomId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  List<String> _currentDialogueOptions = ['Hello! Can we swap?', 'Sure!', 'No, I am busy now!'];

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
    _saveMessages(); // Save messages after adding a new one
  }

  Future<void> _saveMessages() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/messages_${widget.roomId}.json';
    final file = File(path);

    // Convert messages to JSON
    final jsonMessages = _messages.map((msg) => msg.toJson()).toList();

    // Write the messages to the file
    await file.writeAsString(jsonEncode(jsonMessages));
  }


  Future<void> _loadMessages() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/messages_${widget.roomId}.json';
    final file = File(path);

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;

      setState(() {
        _messages = jsonData.map((msg) => types.TextMessage.fromJson(msg)).toList();
      });
    } else {
      // Load initial messages from assets if no file exists
      final response = await rootBundle.loadString('assets/messages.json');
      final initialMessages = (jsonDecode(response) as List)
          .map((e) => types.TextMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages = initialMessages;
      });
      await _saveMessages(); // Save initial messages to file
    }
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Chat with ${widget.user['first_name']}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
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
        _buildDialogueOptions(),
      ],
    ),
  );

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
              onPressed: () => _handleSendPressed(types.PartialText(text: option)),
              child: Text(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
