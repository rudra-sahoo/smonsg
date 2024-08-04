import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FriendService {
  final String baseUrl = 'https://itsrudra.xyz/api/friends';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final BaseCacheManager _cacheManager = DefaultCacheManager();

  // Helper function to get the token from secure storage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Helper function to handle Dio errors
  String _handleError(DioException error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 404:
          return 'Server error, please try again later.';
        case 409:
          return 'Friend request already exists.';
        case 500:
          return 'Internal server error, please try again later.';
        default:
          return 'An unexpected error occurred: ${error.response!.statusCode}';
      }
    } else {
      return 'No internet connection or request timed out.';
    }
  }

  // Send a friend request
  Future<Map<String, dynamic>> sendFriendRequest(
      String requesterUsername, String recipientUsername) async {
    try {
      final token = await _getToken();
      final data = {
        'requesterUsername': requesterUsername,
        'recipientUsername': recipientUsername,
      };
      final response = await _dio.post(
        '$baseUrl/send',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Accept a friend request
  Future<Map<String, dynamic>> acceptFriendRequest(
      String requesterUsername, String recipientUsername) async {
    try {
      final token = await _getToken();
      final data = {
        'requesterUsername': requesterUsername,
        'recipientUsername': recipientUsername,
      };
      final response = await _dio.post(
        '$baseUrl/accept',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Decline a friend request
  Future<Map<String, dynamic>> declineFriendRequest(
      String requesterUsername, String recipientUsername) async {
    try {
      final token = await _getToken();
      final data = {
        'requesterUsername': requesterUsername,
        'recipientUsername': recipientUsername,
      };
      final response = await _dio.post(
        '$baseUrl/decline',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Remove a friend
  Future<Map<String, dynamic>> removeFriend(
      String requesterUsername, String recipientUsername) async {
    try {
      final token = await _getToken();
      final data = {
        'requesterUsername': requesterUsername,
        'recipientUsername': recipientUsername,
      };
      final response = await _dio.post(
        '$baseUrl/remove',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> cancelFriend(
      String requesterUsername, String recipientUsername) async {
    try {
      final token = await _getToken();
      final data = {
        'requesterUsername': requesterUsername,
        'recipientUsername': recipientUsername,
      };
      final response = await _dio.post(
        '$baseUrl/cancel',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Clear friends cache
  Future<void> clearFriendsCache() async {
    try {
      await _cacheManager.emptyCache();
      // ignore: empty_catches
    } catch (e) {}
  }

  // Get all friends for a specific username
  Future<Map<String, dynamic>> getAllFriends(String username,
      {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        var file =
            await _cacheManager.getFileFromCache('$baseUrl/$username/friends');
        if (file != null && file.validTill.isAfter(DateTime.now())) {
          var cachedData = await file.file.readAsString();
          return {'success': true, 'data': jsonDecode(cachedData)};
        }
      }

      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found.'};
      }

      final response = await _dio.get(
        '$baseUrl/$username/friends',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      await _cacheManager.putFile(
        '$baseUrl/$username/friends',
        utf8.encode(jsonEncode(response.data)),
        eTag: response.headers.map['etag']?.first,
      );

      return {'success': true, 'data': response.data};
    } catch (error) {
      if (error is DioException) {
        return {'success': false, 'message': _handleError(error)};
      }
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }
}
