import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smonsg/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _currentUsername;
  final Map<String, Map<String, String>> _cachedUserDetails = {};

  String get currentUsername => _currentUsername ?? '';

  Future<void> fetchCurrentUsername() async {
    _currentUsername = await _secureStorage.read(key: 'username') ?? '';
    notifyListeners();
  }

  Future<Map<String, String>> getUserDetails(String username) async {
    if (_cachedUserDetails.containsKey(username)) {
      return _cachedUserDetails[username]!;
    }

    final userDetails = await _userService.getUserDetails(username);
    _cachedUserDetails[username] = {
      'profilePicture': userDetails['profilePicture'] ??
          'https://your-default-image-url.com/default.jpg',
      'firstName': userDetails['firstName'] ?? username,
    };

    notifyListeners();
    return _cachedUserDetails[username]!;
  }
}
