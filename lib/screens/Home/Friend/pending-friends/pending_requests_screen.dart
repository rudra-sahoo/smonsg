// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:smonsg/providers/friends_provider.dart';
import 'package:smonsg/services/friend_service.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PendingRequestsScreenState createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final FriendService _friendService = FriendService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final username = await _storage.read(key: 'username');
    setState(() {
      _currentUsername = username;
    });
    if (_currentUsername != null) {
      Provider.of<FriendsProvider>(context, listen: false).fetchFriends();
    }
  }

  void _acceptRequest(String requesterUsername) async {
    if (_currentUsername != null) {
      final result = await _friendService.acceptFriendRequest(
          requesterUsername, _currentUsername!);
      if (result['success']) {
        Provider.of<FriendsProvider>(context, listen: false)
            .fetchFriends(forceRefresh: true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  void _declineOrRemoveFriend(String requesterUsername, String role) async {
    if (_currentUsername != null) {
      if (role == 'requester') {
        final result = await _friendService.declineFriendRequest(
            requesterUsername, _currentUsername!);
        if (result['success']) {
          Provider.of<FriendsProvider>(context, listen: false)
              .fetchFriends(forceRefresh: true);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else if (role == 'recipient') {
        final result = await _friendService.cancelFriend(
            requesterUsername, _currentUsername!);
        if (result['success']) {
          Provider.of<FriendsProvider>(context, listen: false)
              .fetchFriends(forceRefresh: true);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FriendsProvider>(
        builder: (context, friendsProvider, child) {
          if (_currentUsername == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (friendsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (friendsProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(friendsProvider.errorMessage));
          } else {
            final pendingRequests = friendsProvider.pendingRequests;

            if (pendingRequests.isEmpty) {
              return const Center(
                child: Text('No pending requests'),
              );
            }

            return ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];

                return Dismissible(
                  key: Key(request['id'].toString()),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _declineOrRemoveFriend(
                          request['username'], request['role']);
                    } else if (direction == DismissDirection.startToEnd &&
                        request['role'] == 'requester') {
                      _acceptRequest(request['username']);
                    } else {
                      // Show a snackbar or animation for invalid action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "You can't perform this action on this request")),
                      );
                    }
                  },
                  background: Container(
                    color: request['role'] == 'requester'
                        ? Colors.green
                        : Colors.transparent,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: request['role'] == 'requester'
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                  secondaryBackground: Container(
                    color: request['role'] == 'recipient'
                        ? Colors.red
                        : Colors.transparent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: request['role'] == 'recipient'
                        ? const Icon(Icons.cancel, color: Colors.white)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(request['profilePicture']),
                    ),
                    title:
                        Text('${request['firstName']} ${request['lastName']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
