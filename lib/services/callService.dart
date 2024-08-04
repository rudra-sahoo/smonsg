import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CallService {
  static const String _backendUrl = 'https://itsrudra.xyz/api/calls'; // Define backend URL here

  final FlutterSecureStorage storage;
  final Dio dio;

  CallService({required this.storage})
      : dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 8000),
        ));

  Future<Map<String, dynamic>> initiateCall(String receiverUsername, String callType) async {
    final callerUsername = await storage.read(key: 'username');
    if (callerUsername == null) {
      throw Exception('Caller username not found in secure storage');
    }

    final authToken = await storage.read(key: 'token');
    if (authToken == null) {
      throw Exception('Authorization token not found in secure storage');
    }

    try {
      final response = await dio.post(
        '$_backendUrl/initiateCall', // Use the backend URL constant
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
        data: {
          'callerUsername': callerUsername,
          'receiverUsername': receiverUsername,
          'callType': callType,
        },
      );

      if (response.statusCode == 200) {
        // Extract call details from the response
        final data = response.data;
        final agoraToken = data['agoraToken'];
        final channelName = data['channelName'];
        final callerUid = data['callerUid'];
        final receiverUid = data['receiverUid'];

        // Handle successful response
        
        // Return call details
        return {
          'agoraToken': agoraToken,
          'channelName': channelName,
          'callerUid': callerUid,
          'receiverUid': receiverUid,
        };
      } else {
        // Handle error response
        throw Exception('Error initiating call: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error initiating call: $e');
    }
  }
}
