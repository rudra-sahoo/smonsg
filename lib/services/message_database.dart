import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class MessageDatabase {
  // Save message locally
  Future<void> saveMessage(String senderUsername, String receiverUsername,
      String message, bool isSentByMe) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getChatFileName(senderUsername, receiverUsername);
    final chatFile = File('${directory.path}/$fileName');

    List<dynamic> messages = [];
    if (await chatFile.exists()) {
      final contents = await chatFile.readAsString();
      messages = json.decode(contents);
    }

    messages.add({
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isSentByMe': isSentByMe,
    });

    await chatFile.writeAsString(json.encode(messages));
  }

  // Fetch list of users chatted with
  Future<List<String>> getChattedUsers() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    Set<String> users = {};

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final fileName = file.path.split('/').last;
        final usernames = fileName.replaceAll('.json', '').split('_');
        if (usernames.length == 2) {
          users.add(usernames[0]);
          users.add(usernames[1]);
        }
      }
    }
    final currentUsername = await _getCurrentUsername();
    users.remove(currentUsername);
    return users.toList();
  }

  // Fetch chats for a specific user
  Future<List<Map<String, dynamic>>> getChatsForUser(String username) async {
    final currentUsername = await _getCurrentUsername();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getChatFileName(currentUsername, username);
    final chatFile = File('${directory.path}/$fileName');

    if (!await chatFile.exists()) {
      return [];
    }

    final contents = await chatFile.readAsString();
    return List<Map<String, dynamic>>.from(json.decode(contents));
  }

  // Delete chat file for specific user
  Future<void> deleteChatFile(String user1, String user2) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getChatFileName(user1, user2);
    final chatFile = File('${directory.path}/$fileName');

    if (await chatFile.exists()) {
      await chatFile.delete();
    } else {}
  }

  // Helper method to generate consistent chat file names
  String _getChatFileName(String user1, String user2) {
    final users = [user1, user2];
    users.sort();
    return '${users[0]}_${users[1]}.json';
  }

  Future<String> _getCurrentUsername() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'username') ?? '';
  }
}
