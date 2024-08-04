import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'message_database.dart';

class MessageService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl =
      'https://itsrudra.xyz'; // Replace with your API base URL
  final MessageDatabase _messageDatabase = MessageDatabase();

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;

  // Method to send message (no encryption/decryption)
  Future<void> sendMessage(String receiverUsername, String message) async {
    try {
      final String? token = await _storage.read(key: 'token');
      final String? senderUsername = await _storage.read(key: 'username');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }
      if (senderUsername == null) {
        throw Exception('Sender username not found.');
      }

      final response = await _dio.post(
        '$_baseUrl/api/message/sendMessage',
        data: {
          'senderUsername': senderUsername,
          'receiverUsername': receiverUsername,
          'message': message, // Send message directly without encryption
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      // Save the sent message locally
      await _messageDatabase.saveMessage(
          senderUsername, receiverUsername, message, true);

      // ignore: empty_catches
    } catch (e) {}
  }

  // Fetch list of users chatted with
  Future<List<String>> getChattedUsers() async {
    final String? currentUser = await _storage.read(key: 'username');
    if (currentUser == null) {
      throw Exception('Current user not found.');
    }

    final users = await _messageDatabase.getChattedUsers();
    // Filter out the current user from the list
    return users.where((user) => user != currentUser).toList();
  }

  // Fetch chats for a specific user
  Future<List<Map<String, dynamic>>> getChatsForUser(String username) async {
    final messages = await _messageDatabase.getChatsForUser(username);
    return messages;
  }

  // This method should be called whenever a new message is received
  void onMessageReceived(Map<String, dynamic> message) {
    _messageController.add(message);
  }

  // Method to acknowledge receipt of a message
  Future<void> acknowledgeMessage() async {
    try {
      final String? receiverUsername = await _storage.read(key: 'username');
      if (receiverUsername == null) {
        throw Exception('Receiver username not found.');
      }

      final String acknowledgmentUrl = '$_baseUrl/api/ack/acknowledgeMessage';

      final response = await _dio.post(
        acknowledgmentUrl,
        data: {
          'receiverUsername': receiverUsername,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _storage.read(key: 'token')}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to acknowledge message: ${response.statusCode}');
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
