import 'package:flutter/foundation.dart';
import 'package:smonsg/services/user_service.dart';
// For storing binary data
import 'package:dio/dio.dart';

class QRCodeProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  String? _qrUrl;
  Uint8List? _qrContent; // Add this to store the QR code content
  bool _isLoading = false;

  String? get qrUrl => _qrUrl;
  Uint8List? get qrContent => _qrContent; // Add this getter
  bool get isLoading => _isLoading;

  Future<void> fetchQRCodeUrl(String username) async {
    if (_qrUrl != null) {
      // QR code is already fetched
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _qrUrl = await _userService.getQRCodeUrl(username);
      _qrContent =
          await _fetchQRCodeContent(_qrUrl!); // Fetch and store content
    } catch (e) {
      // Handle error
      _qrUrl = null;
      _qrContent = null; // Reset content on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateQRCode(String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      _qrUrl = await _userService.generateQRCode(username);
      _qrContent =
          await _fetchQRCodeContent(_qrUrl!); // Fetch and store content
    } catch (e) {
      // Handle error
      _qrUrl = null;
      _qrContent = null; // Reset content on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearQRCode() async {
    _qrUrl = null;
    _qrContent = null; // Clear content
    notifyListeners();
  }

  Future<Uint8List> _fetchQRCodeContent(String url) async {
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
}
