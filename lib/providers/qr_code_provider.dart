import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeProvider extends ChangeNotifier {
  Uint8List? qrContent;
  bool isLoading = false;
  Color? lastColor;

  /// Generates the QR code with the provided [data] and [color].
  Future<void> generateQRCode(String data, Color color) async {
  isLoading = true;
  notifyListeners();

  try {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: color,
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction level
    );

    final image = await qrPainter.toImage(1000); // Increased size to 1000x1000 pixels
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    qrContent = byteData?.buffer.asUint8List();

    lastColor = color;
  } catch (e) {
    print("QR generation error: $e");
    qrContent = null;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  /// Returns the color in which the QR was last generated.
  Color get lastUsedColor => lastColor ?? Colors.orange; // Default color is orange if none is set

  /// Randomizes the color and generates the QR code with the provided [data].
  void changeColor(String data) {
  final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  generateQRCode(data, randomColor);
  lastColor = randomColor; // Store the last selected color
}
}
