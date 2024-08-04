import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smonsg/screens/Home/home_screen.dart';
import 'package:smonsg/services/auth_service.dart'; // Import your AuthService
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging package

class OTPPage extends StatefulWidget {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String userProfileImage;

  const OTPPage({
    super.key,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userProfileImage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isButtonDisabled = true;
  bool _isLoading = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions(); // Request notification permissions on init
    _firebaseMessaging.getToken().then((token) {
      // Send token to backend using your API service
      _sendTokenToBackend(token!);
    });
  }

  // Request notification permissions
  void _requestNotificationPermissions() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else {}
  }

  // Send FCM token to backend
  void _sendTokenToBackend(String token) async {
    // Call your API service to save token in backend
    // Example:
    // AuthService authService = AuthService(); // Instantiate your AuthService
    // authService.saveFCMToken(token);
  }

  Future<void> _saveUserData(
    String username,
    String firstName,
    String lastName,
    String email,
    String token,
    String profileImage,
    String avatarImage,
    String dob,
    String gender,
  ) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'firstName', value: firstName);
    await _secureStorage.write(key: 'lastName', value: lastName);
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'token', value: token);
    await _secureStorage.write(key: 'profileImage', value: profileImage);
    await _secureStorage.write(key: 'avatarImage', value: avatarImage);
    await _secureStorage.write(key: 'dob', value: dob);
    await _secureStorage.write(key: 'gender', value: gender);
  }

  Future<void> _verifyOTPAndNavigate(BuildContext context, String otp) async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService(); // Instantiate your AuthService
    String fcmToken = await _firebaseMessaging.getToken() ?? '';
    Map<String, dynamic> result = await authService.verifyOTP(
        widget.email, widget.userName, otp, fcmToken);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      String token = result['token'] ?? '';
      await _saveUserData(
        result['username'] ?? widget.userName,
        result['firstName'] ?? widget.firstName,
        result['lastName'] ?? widget.lastName,
        widget.email,
        token,
        result['profileImage'] ?? '',
        result['avatarImage'] ?? '',
        result['dob'] ?? '',
        result['gender'] ?? '',
      );
      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: result['username'] ?? widget.userName,
            email: widget.email,
            token: token,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('OTP Verification Failed'),
          content: Text(result['message'] ?? 'Unknown error occurred'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _onOTPChanged(String value) {
    setState(() {
      _isButtonDisabled = value.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: const Center(
          child: Text('Verification'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Golden circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber, // golden color
                  ),
                ),
                // Circle Avatar with profile image
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.userProfileImage),
                  radius: 50,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome back, ${widget.firstName} ${widget.lastName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('OTP sent to email: ${widget.email}'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter OTP';
                }
                return null;
              },
              onChanged: _onOTPChanged,
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  _verifyOTPAndNavigate(context, value);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isButtonDisabled || _isLoading
              ? null
              : () {
                  _verifyOTPAndNavigate(context, _otpController.text);
                },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _isLoading ? Colors.grey : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text('Verify OTP'),
        ),
      ),
    );
  }
}
