import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {

  final types.Room room;
  const ChatPage({super.key, required this.room});


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

  void _loadMessages() {
    FirebaseChatCore.instance.messages(widget.room).listen((snapshot) {
      setState(() {
        _messages = snapshot;
      });
    });
  }



  void _handleMessageTap(BuildContext _, types.Message message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    FirebaseChatCore.instance.sendMessage(
      textMessage,
      widget.room.id,
    );

    setState(() {
      _currentDialogueOptions = _dialogueFlows[message.text] ?? [];
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.room.name ?? 'Chat Room'),
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