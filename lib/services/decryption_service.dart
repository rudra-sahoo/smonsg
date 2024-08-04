import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class DecryptionService {
  static const String _key =
      'ahguTyRo0pOPajbnfajbfjabfajbfauf'; // Same key used for encryption
  static final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(_key.substring(0, 32))));

  // Decrypt a message
  String decryptMessage(String encryptedMessage) {
    try {
      final Map<String, dynamic> decodedMessage = jsonDecode(encryptedMessage);
      final iv = encrypt.IV.fromBase64(decodedMessage['iv']);
      final encrypted = encrypt.Encrypted.fromBase64(decodedMessage['message']);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      return 'Error decrypting message';
    }
  }
}
