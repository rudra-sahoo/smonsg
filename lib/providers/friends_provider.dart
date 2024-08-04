import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smonsg/services/friend_service.dart';

class FriendsProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<dynamic> _friends = [];
  bool _loading = false;
  String _errorMessage = '';

  FriendsProvider() {
    fetchFriends(); // Automatically fetch friends on initialization
  }

  List<dynamic> get friends =>
      _friends.where((friend) => friend['status'] == 'accepted').toList();
  List<dynamic> get pendingRequests =>
      _friends.where((friend) => friend['status'] == 'pending').toList();
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  Future<void> fetchFriends({bool forceRefresh = false}) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result = await _friendService.getAllFriends(username,
            forceRefresh: forceRefresh);
        if (result['success']) {
          _friends = result['data'];
        } else {
          _errorMessage = result['message'] ?? 'Failed to fetch friends';
        }
      } else {
        _errorMessage = 'Username not found in secure storage.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching friends: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest(String recipientUsername) async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result =
            await _friendService.sendFriendRequest(username, recipientUsername);
        if (result['success']) {
          // Handle successful friend request
          // Trigger notifications here for both sender and receiver
          fetchFriends(forceRefresh: true);
          notifyListeners();
        } else {
          _errorMessage = result['message'] ?? 'Failed to send friend request';
        }
      }
    } catch (e) {
      _errorMessage = 'Error sending friend request: $e';
    }
  }

  Future<void> acceptFriendRequest(String requesterUsername) async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result = await _friendService.acceptFriendRequest(
            requesterUsername, username);
        if (result['success']) {
          // Handle successful acceptance
          // Trigger notifications here for both sender and receiver
          fetchFriends(forceRefresh: true);
          notifyListeners();
        } else {
          _errorMessage =
              result['message'] ?? 'Failed to accept friend request';
        }
      }
    } catch (e) {
      _errorMessage = 'Error accepting friend request: $e';
    }
  }

  Future<void> declineFriendRequest(String requesterUsername) async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result = await _friendService.declineFriendRequest(
            requesterUsername, username);
        if (result['success']) {
          // Handle successful decline
          fetchFriends(forceRefresh: true);
          notifyListeners();
        } else {
          _errorMessage =
              result['message'] ?? 'Failed to decline friend request';
        }
      }
    } catch (e) {
      _errorMessage = 'Error declining friend request: $e';
    }
  }

  Future<void> removeFriend(String friendUsername) async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result =
            await _friendService.removeFriend(username, friendUsername);
        if (result['success']) {
          // Handle successful removal
          fetchFriends(forceRefresh: true);
          notifyListeners();
        } else {
          _errorMessage = result['message'] ?? 'Failed to remove friend';
        }
      }
    } catch (e) {
      _errorMessage = 'Error removing friend: $e';
    }
  }

  Future<void> cancelFriendRequest(String recipientUsername) async {
    try {
      final username = await _storage.read(key: 'username');
      if (username != null) {
        final result =
            await _friendService.cancelFriend(username, recipientUsername);
        if (result['success']) {
          // Handle successful cancellation
          fetchFriends(forceRefresh: true);
          notifyListeners();
        } else {
          _errorMessage =
              result['message'] ?? 'Failed to cancel friend request';
        }
      }
    } catch (e) {
      _errorMessage = 'Error canceling friend request: $e';
    }
  }
}
