import 'dart:async';

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
  StreamSubscription? _messagesSubscription;
  List<String> _currentDialogueOptions = ['Hello! Can we swap?', 'Ok thanks!'];
  bool _canSendMessage = true; // Controls whether the user can send a message

  final Map<String, List<String>> _dialogueFlows = {
    'Hello! Can we swap?': ['Sure!', 'No, I am busy now!'],
    'Sure!': ['Give me 5 minutes', 'Give me 15 minutes', 'Give me 25 minutes'],
    'No, I am busy now!': ['Sorry!'],
    'Give me 5 minutes': ['Thanks!'],
    'Give me 15 minutes': ['Thanks!'],
    'Give me 25 minutes': ['Thanks!'],
    'Thanks!': [],
  };

  String _lastSentMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Load existing messages from Firestore
  void _loadMessages() {
    _messagesSubscription = FirebaseChatCore.instance.messages(widget.room).listen((messages) {
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        if (lastMessage is types.TextMessage) {
          // If the last message is from the other user, allow sending again
          if (lastMessage.author.id != widget.user.id) {
            setState(() {
              _canSendMessage = true;
              _currentDialogueOptions = _dialogueFlows[lastMessage.text] ?? [];
            });
          }
        }
      }
    });
  }

  // Handle message send
  Future<void> _handleSendPressed(types.PartialText message) async {
    if (!_canSendMessage) return; // Block message sending if not allowed

    final textMessage = types.TextMessage(
      author: widget.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    // Optimistically add the message to Firestore
    try {
      final messageMap = textMessage.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = widget.user.id;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('rooms/${widget.room.id}/messages')
          .add(messageMap);

      // Update dialogue options and block further sending
      setState(() {
        _lastSentMessage = message.text;
        _currentDialogueOptions = _dialogueFlows[message.text] ?? [];
        _canSendMessage = false; // Block sending until the other user responds
      });
    } catch (e) {
      print("Error adding message: $e");
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
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
            initialData: const [],
            stream: FirebaseChatCore.instance.messages(widget.room),
            builder: (context, snapshot) {
              return Chat(
                messages: snapshot.data ?? [],
                onSendPressed: _handleSendPressed,
                user: widget.user,
                showUserAvatars: true,
                showUserNames: true,
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
              onPressed: _canSendMessage
                  ? () => _handleSendPressed(types.PartialText(text: option))
                  : null, // Disable button if sending is blocked
              child: Text(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
