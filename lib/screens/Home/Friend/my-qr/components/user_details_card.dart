import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:smonsg/services/friend_service.dart'; // Ensure this is correctly imported or adjusted

class UserDetailsCard extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  const UserDetailsCard({super.key, required this.userDetails});

  @override
  // ignore: library_private_types_in_public_api
  _UserDetailsCardState createState() => _UserDetailsCardState();
}

class _UserDetailsCardState extends State<UserDetailsCard> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FriendService _friendService = FriendService();
  String _errorMessage = '';
  bool _showError = false;

  String formatDate(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  Future<void> _sendFriendRequest(String recipientUsername) async {
    try {
      final requesterUsername = await _storage.read(key: 'username');
      if (requesterUsername != null) {
        final response = await _friendService.sendFriendRequest(
            requesterUsername, recipientUsername);
        if (response['success']) {
          // Successfully sent friend request
          setState(() {
            _showError = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          // Handle error response
          setState(() {
            _errorMessage = response['message'];
            _showError = true;
          });
          // Delay before closing the card to show error message
          await Future.delayed(const Duration(seconds: 2));
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = 'Requester username not found';
          _showError = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending friend request: $e';
        _showError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Handle tap outside card if needed
              },
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          NetworkImage(widget.userDetails['profilePicture']),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.userDetails['firstName']} ${widget.userDetails['lastName']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Member since ${formatDate(widget.userDetails['createdAt'])}'),
                    const SizedBox(height: 16),
                    if (_showError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.horizontal,
                      dragStartBehavior: DragStartBehavior.start,
                      onDismissed: (direction) async {
                        final recipientUsername =
                            widget.userDetails['username'];

                        if (direction == DismissDirection.startToEnd) {
                          // Send friend request logic
                          await _sendFriendRequest(recipientUsername);
                        } else if (direction == DismissDirection.endToStart) {
                          Navigator.of(context).pop();
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      child: Container(
                        width: 300, // Adjusted the width of the card
                        height: 80,
                        alignment: Alignment.center,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: const Icon(Icons.swap_horiz,
                              size: 30, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
