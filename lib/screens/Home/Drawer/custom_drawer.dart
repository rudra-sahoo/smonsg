import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Make sure to import widgets for ImageFiltered
import 'about_us_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.onLogout,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _profileImage = '';
  String _firstName = '';
  String _greetingMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setGreetingMessage();
  }

  Future<void> _loadUserData() async {
    String? profileImage = await _secureStorage.read(key: 'profileImage');
    String? firstName = await _secureStorage.read(key: 'firstName');

    setState(() {
      _profileImage = profileImage ?? '';
      _firstName = firstName ?? 'User';
    });
  }

  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greetingMessage = 'Good Morning';
    } else if (hour < 17) {
      _greetingMessage = 'Good Afternoon';
    } else if (hour < 20) {
      _greetingMessage = 'Good Evening';
    } else {
      _greetingMessage = 'Good Night';
    }
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          // Background blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black
                    .withOpacity(0), // Optional: add a semi-transparent color
              ),
            ),
          ),
          // Drawer content
          Container(
            height: MediaQuery.of(context).size.height *
                0.65, // 65% of screen height
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30.0), // Rounded bottom-left corner
                bottomRight:
                    Radius.circular(30.0), // Rounded bottom-right corner
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _profileImage.isNotEmpty
                              ? NetworkImage(_profileImage)
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text('Welcome $_firstName',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          _greetingMessage,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text('Profile',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text('Settings',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.white),
                    title: const Text('About Us',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
                    onTap: widget.onLogout,
                  ),
                  const SizedBox(
                      height: 10), // Adjust spacing before the closing icon
                  GestureDetector(
                    onTap: _closeDrawer,
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.keyboard_arrow_up,
                            color: Colors.white, size: 16),
                        const SizedBox(height: 4),
                        Container(
                          height: 1,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
