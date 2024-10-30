import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

chat_firebase() async {
  await FirebaseChatCore.instance.createUserInFirestore(
    types.User(
      firstName: 'John',
      id: credential.user!.uid, // UID from Firebase Authentication
      imageUrl: 'https://i.pravatar.cc/300',
      lastName: 'Doe',
    ),
  );
}
