import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:light/light.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smonsg/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  late Light _light;
  StreamSubscription? _subscription;
  bool _isFlashOn = false;
  bool _isFlashlightPermissionGranted = false;
  final UserService _userService = UserService();
  final storage = const FlutterSecureStorage();
  late String? storedUsername;

  late AnimationController _animationController;

  late AnimationController _warningAnimationController;
  bool _isShowingWarning = false;
  String _warningText = '';
  Color _warningColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadStoredUsername();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _warningAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _warningAnimationController.dispose();
    controller?.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        _isFlashlightPermissionGranted = true;
      });
      _initLightSensor();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to use the flashlight.'),
        ),
      );
    }
  }

  Future<void> _loadStoredUsername() async {
    storedUsername = await storage.read(key: 'username');
  }

  void _initLightSensor() {
    _light = Light();
    _subscription = _light.lightSensorStream.listen((luxValue) {
      if (luxValue < 10 && !_isFlashOn) {
        controller?.toggleFlash();
        setState(() {
          _isFlashOn = true;
        });
      } else if (luxValue >= 10 && _isFlashOn) {
        controller?.toggleFlash();
        setState(() {
          _isFlashOn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          _buildWarningAnimation(),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return _isFlashlightPermissionGranted
        ? Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
              _buildWarningAnimation(),
            ],
          )
        : Center(
            child: ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text('Request Camera Permission'),
            ),
          );
  }

  Widget _buildWarningAnimation() {
    return AnimatedBuilder(
      animation: _warningAnimationController,
      builder: (context, child) {
        return _isShowingWarning
            ? Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: _warningColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _warningText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }

  void _onQRViewCreated(QRViewController qrViewController) {
    controller = qrViewController;
    qrViewController.scannedDataStream.listen((scanData) async {
      qrViewController.pauseCamera();
      String? scannedData = scanData.code;

      if (scannedData != null) {
        if (scannedData.startsWith("XTRF-SI")) {
          scannedData = scannedData.substring("XTRF-SI".length);

          // Check if the scanned username matches the stored username
          if (scannedData == storedUsername) {
            debugPrint('Scanned the same user'); // Debug statement
            _showSameUserWarning();
            qrViewController.resumeCamera();
          } else {
            try {
              Map<String, dynamic> userDetails =
                  await _userService.getUserDetails(scannedData);
              debugPrint(
                  'User Details fetched: $userDetails'); // Debug statement
              _animationController.forward(from: 0.0);
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context, userDetails);
                _animationController.reverse();
              });
            } catch (e) {
              debugPrint('Failed to fetch user details: $e'); // Debug statement
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to fetch user details: $e')),
              );
              qrViewController.resumeCamera();
            }
          }
        } else {
          // Handle invalid QR code format
          debugPrint('Invalid QR code'); // Debug statement
          _showInvalidQRWarning();
          qrViewController.resumeCamera();
        }
      }
    });
  }

  void _showInvalidQRWarning() {
    setState(() {
      _isShowingWarning = true;
      _warningText = 'Please scan a valid QR code';
      _warningColor = Colors.red;
    });
    _warningAnimationController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 2), () {
      _warningAnimationController.reverse();
      setState(() {
        _isShowingWarning = false;
      });
    });
  }

  void _showSameUserWarning() {
    setState(() {
      _isShowingWarning = true;
      _warningText = 'Same User';
      _warningColor = Colors.green;
    });
    _warningAnimationController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 2), () {
      _warningAnimationController.reverse();
      setState(() {
        _isShowingWarning = false;
      });
    });
  }
}
