import 'package:flutter/material.dart';
import 'package:smonsg/screens/Home/Friend/my-qr/my_qr_screen.dart';
import 'package:smonsg/screens/Home/Friend/friends/friends_list_screen.dart';
import 'pending-friends/pending_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _onOptionSelected(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MyQRScreen(),
      const FriendsListScreen(),
      const PendingRequestsScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          // Options at the top
          Container(
            color: Colors.black,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOption('MY QR', 0),
                    _buildOption('FRIENDS', 1),
                    _buildOption('PENDING REQUESTS', 2),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left:
                      MediaQuery.of(context).size.width / 3 * _currentPageIndex,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 2.0,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // PageView for swiping between pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onOptionSelected(index),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.transparent, // Ensure the container is clickable
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: _currentPageIndex == index ? Colors.blue : Colors.white,
              fontWeight: _currentPageIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 6.0, // Adjusted font size for better visibility
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
