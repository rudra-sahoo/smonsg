import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _email;
  String? _username;
  String? _token;

  String? get email => _email;
  String? get username => _username;
  String? get token => _token;

  Future<void> loadUserData() async {
    _email = await _secureStorage.read(key: 'email');
    _username = await _secureStorage.read(key: 'username');
    _token = await _secureStorage.read(key: 'token');
    notifyListeners();
  }

  void setUser(String email, String username, String token) {
    _email = email;
    _username = username;
    _token = token;
    _secureStorage.write(key: 'email', value: email);
    _secureStorage.write(key: 'username', value: username);
    _secureStorage.write(key: 'token', value: token);
    notifyListeners();
  }

  void clearUser() {
    _email = null;
    _username = null;
    _token = null;
    _secureStorage.delete(key: 'email');
    _secureStorage.delete(key: 'username');
    _secureStorage.delete(key: 'token');
    notifyListeners();
  }
}
