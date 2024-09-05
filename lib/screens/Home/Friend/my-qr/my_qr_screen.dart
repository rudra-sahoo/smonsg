import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smonsg/providers/qr_code_provider.dart';
import 'package:smonsg/providers/friends_provider.dart'; // Import the FriendsProvider
import 'components/qr_scanner_screen.dart';
import 'components/user_details_card.dart';

class MyQRScreen extends StatefulWidget {
  const MyQRScreen({super.key});

  @override
  _MyQRScreenState createState() => _MyQRScreenState();
}

class _MyQRScreenState extends State<MyQRScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String username = ''; // Initialize with empty string
  bool _hasFetchedFriends = false; // Flag to track if friends data has been fetched

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await fetchUserData(); // Fetch the user data first

    // Fetch friends only if it hasn't been done before
    if (!_hasFetchedFriends) {
      fetchFriends(forceRefresh: true); // Forcefully fetch the first time
      _hasFetchedFriends = true; // Update the flag after fetching
    }

    generateUserQRCode(); // Generate the QR code
  }

  Future<void> fetchUserData() async {
    try {
      username = await _secureStorage.read(key: 'username') ?? 'Unknown.User';
      setState(() {});
    } catch (e) {
      setState(() {
        username = 'Unknown.User';
      });
    }
  }

  /// Fetches all friends using the FriendsProvider.
  void fetchFriends({bool forceRefresh = false}) {
    final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
    friendsProvider.fetchFriends(forceRefresh: forceRefresh);
  }

  /// Generates the user's QR code using the QRCodeProvider.
  void generateUserQRCode() {
    final qrCodeProvider = Provider.of<QRCodeProvider>(context, listen: false);
    final prefixedData = 'XTRF-SI$username';
    final color = qrCodeProvider.lastColor ?? Colors.blue; // Use lastColor if it's not null
    qrCodeProvider.generateQRCode(prefixedData, color);
  }

  Future<void> shareQRCode(Uint8List qrContent) async {
    if (qrContent.isEmpty) {
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/qr_code.png';
    final file = File(filePath);
    await file.writeAsBytes(qrContent);

    final result = await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Here is my QR code!',
    );

    if (result.status == ShareResultStatus.dismissed) {
      print('User dismissed the share dialog.');
    }
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
                GestureDetector(
                  onTap: () {
                    final newColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
                    qrCodeProvider.lastColor = newColor; // Update lastColor here
                    final prefixedData = 'XTRF-SI$username';
                    qrCodeProvider.generateQRCode(prefixedData, newColor);
                  },
                  child: Container(
                    width: 300.0,
                    height: 300.0,
                    margin: const EdgeInsets.only(bottom: 50.0),
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
                            : Container(),
                  ),
                ),
                ElevatedButton(
                  onPressed: qrCodeProvider.qrContent != null
                      ? () => shareQRCode(qrCodeProvider.qrContent!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Share'),
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
                  debugPrint('Navigator returned: $userDetails');
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
