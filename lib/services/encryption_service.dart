import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptionService {
  static const String _key = 'ahguTyRo0pOPajbnfajbfjabfajbfauf'; // Replace with your own key (must be 16, 24, or 32 bytes)
  static final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(_key.substring(0, 32))));

  // Encrypt a message
  String encryptMessage(String message) {
    final iv = encrypt.IV.fromSecureRandom(16); // Generate a secure random IV
    final encrypted = encrypter.encrypt(message, iv: iv);
    final encryptedMessage = jsonEncode({
      'iv': iv.base64,
      'message': encrypted.base64,
    });
    return encryptedMessage;
  }
}
