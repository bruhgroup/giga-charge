import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:uuid/uuid.dart';

import '../swap/swap_confirmation.dart';

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

  String _generateOTP() {
    if (kDebugMode) return '123456';
    const random = Uuid();
    return random.v4().substring(0, 6); // Take the first 6 characters for a simple OTP
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

  Future<void> _handleSendPressed(types.PartialText message) async {
    if (!_canSendMessage) return;

    String otp = ''; // Hold OTP if needed
    String updatedMessage = message.text;

    // Special handling for "Sure!"
    if (message.text == 'Sure!') {
      otp = _generateOTP();
      updatedMessage = 'Sure! Your OTP is $otp #OTP click here to swap!';
      setState(() {
        _currentDialogueOptions = ['Send OTP: $otp', 'Cancel']; // Add Send/Cancel options
      });
    } else if (message.text.startsWith('Send OTP:')) {
      // Handle sending the OTP (you can integrate with your backend or messaging API here)
      setState(() {
        _currentDialogueOptions = ['Thanks!'];
      });
    } else if (message.text == 'Cancel') {
      setState(() {
        _currentDialogueOptions = ['Sorry!'];
      });
      return; // Skip sending the Cancel message
    }

    final textMessage = types.TextMessage(
      author: widget.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: updatedMessage,
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

      setState(() {
        _lastSentMessage = updatedMessage;
        _currentDialogueOptions = _dialogueFlows[message.text] ?? [];
        _canSendMessage = false;
      });
    } catch (e) {
      // print("Error adding message: $e");
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
                onMessageTap: (context, message) {
                  if (message is types.TextMessage && message.text.contains('#OTP')) {
                    // Navigate to Swap Confirmation Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SwapConfirmationPage()),
                    );
                  }
                },
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
