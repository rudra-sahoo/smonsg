import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blur/blur.dart';
import 'package:smonsg/screens/Welcome/welcome_screen.dart';
import 'calls_screen.dart';
import 'Friend/friends_screen.dart';
import 'Drawer/custom_drawer.dart';
import 'chat/user_list/userlist.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String token;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.token,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImageUrl();
  }

  void _loadProfileImageUrl() async {
    String? url = await _secureStorage.read(key: 'profileImage');
    setState(() {
      _profileImageUrl = url;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _secureStorage.deleteAll(); // Delete all secure storage data
    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _openTopDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Top Drawer',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: CustomDrawer(onLogout: _logout),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const UserListScreen(),
      const FriendsScreen(),
      const CallsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey, // Assigning the scaffold key
      appBar: AppBar(
        title: const Text(
          'SMONSG',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap:
                _openTopDrawer, // Open the drawer only when this icon is tapped
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null,
              child: _profileImageUrl == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          pages.elementAt(_selectedIndex),
          Positioned(
            bottom: 20, // Add some margin from the bottom
            left: MediaQuery.of(context).size.width * 0.1, // Adjust left margin
            right:
                MediaQuery.of(context).size.width * 0.1, // Adjust right margin
            child: Stack(
              children: [
                Blur(
                  blur: 10,
                  blurColor: Colors.black.withOpacity(0.2),
                  child: Container(
                    height: 60.0,
                    decoration: BoxDecoration(
                      color:
                          Colors.transparent, // Make the container transparent
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.chat,
                          color:
                              _selectedIndex == 0 ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          _onItemTapped(0);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.people,
                          color:
                              _selectedIndex == 1 ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          _onItemTapped(1);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.call,
                          color:
                              _selectedIndex == 2 ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          _onItemTapped(2);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
