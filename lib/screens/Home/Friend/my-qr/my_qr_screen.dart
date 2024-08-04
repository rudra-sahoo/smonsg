// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:smonsg/providers/qr_code_provider.dart';
import 'components/qr_scanner_screen.dart';
import 'components/user_details_card.dart';

class MyQRScreen extends StatefulWidget {
  const MyQRScreen({super.key});

  @override
  _MyQRScreenState createState() => _MyQRScreenState();
}

class _MyQRScreenState extends State<MyQRScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late String username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      final storedUsername = await _secureStorage.read(key: 'username');
      setState(() {
        username = storedUsername!;
      });
    } catch (e) {
      // Handle error
    }
  }

  void generateQRCode() {
    if (username.isEmpty) {
      // Handle empty username
      return;
    }
    final qrCodeProvider = Provider.of<QRCodeProvider>(context, listen: false);
    qrCodeProvider.generateQRCode(username);
  }

  void _showUserDetailsDialog(Map<String, dynamic> userDetails) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: UserDetailsCard(userDetails: userDetails),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrCodeProvider = Provider.of<QRCodeProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 300.0,
                  height: 300.0,
                  margin: const EdgeInsets.only(bottom: 50.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 2.0),
                  ),
                  child: qrCodeProvider.isLoading
                      ? const Center(
                          child: SpinKitFadingCircle(
                            color: Colors.blue,
                            size: 50.0,
                          ),
                        )
                      : qrCodeProvider.qrContent != null
                          ? Image.memory(
                              qrCodeProvider.qrContent!,
                              width: 300.0,
                              height: 300.0,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Text('Generate a QR'),
                            ),
                ),
                ElevatedButton(
                  onPressed: generateQRCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Generate QR Code'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () async {
                final userDetails = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
                if (userDetails != null) {
                  debugPrint(
                      'Navigator returned: $userDetails'); // Debug statement
                  setState(() {});
                  _showUserDetailsDialog(userDetails);
                }
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}
