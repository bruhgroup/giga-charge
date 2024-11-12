import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final types.Room room;
  final types.User user;
  const ChatPage({super.key, required this.room, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
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

  // Load messages and listen to real-time updates
  void _loadMessages() {
    FirebaseChatCore.instance.messages(widget.room).listen((snapshot) {
      setState(() {
        _messages = snapshot;
      });
    });
  }

  // Handle tap on message
  void _handleMessageTap(BuildContext _, types.Message message) {
    FirebaseChatCore.instance.sendMessage(message, widget.room.id);
  }

  // Handle message send
  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: widget.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    // Optimistically add the message to the UI
    setState(() {
      _messages.insert(0, textMessage);
    });

    // Prepare the message map for Firestore
    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = widget.user.id;
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    // Add message to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('rooms/${widget.room.id}/messages')
          .add(messageMap);
    } catch (e) {
      print("Error adding message: $e");
    }

    // Update the dialogue options based on the sent message
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
          child: StreamBuilder<List<types.Message>>(
            stream: FirebaseChatCore.instance.messages(widget.room),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final messages = snapshot.data ?? [];
              return Chat(
                messages: messages,
                onMessageTap: _handleMessageTap,
                user: widget.user,
                showUserAvatars: true,
                showUserNames: true,
                onSendPressed: _handleSendPressed,
              );
            },
          ),
        ),
        _buildDialogueOptions(),
      ],
    ),
  );

  // Build dialogue options based on current flow
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
