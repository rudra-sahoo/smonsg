import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../providers/friends_provider.dart';
import '../../../../services/friend_service.dart';
import '../../chat/chat_screen/chats_screen.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final FriendService _friendService = FriendService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late String _currentUsername;

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendsProvider>(context, listen: false).fetchFriends();
    });
  }

  Future<void> _getCurrentUsername() async {
    _currentUsername = await _secureStorage.read(key: 'username') ?? '';
    setState(() {}); // Update state to reflect the fetched username
  }

  Future<void> _refreshFriendsList() async {
    await Provider.of<FriendsProvider>(context, listen: false).fetchFriends();
  }

  Future<void> _removeFriend(String friendUsername) async {
    final result =
        await _friendService.removeFriend(_currentUsername, friendUsername);
    if (result['success']) {
      // ignore: use_build_context_synchronously
      Provider.of<FriendsProvider>(context, listen: false).fetchFriends();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
      ));
    }
  }

  Future<void> _showRemoveFriendDialog(
      String friendFirstName, String friendUsername) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Friend'),
          content: Text('Are you sure you want to remove $friendFirstName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _removeFriend(friendUsername);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FriendsProvider>(
        builder: (context, friendsProvider, child) {
          if (friendsProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (friendsProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(friendsProvider.errorMessage));
          } else if (friendsProvider.friends.isEmpty) {
            return const Center(child: Text('Add friends to start talking.'));
          } else {
            final friends = friendsProvider.friends;

            return RefreshIndicator(
              onRefresh: _refreshFriendsList,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: friends.length,
                itemBuilder: (context, index, animation) {
                  if (index < 0 || index >= friends.length) {
                    return const SizedBox
                        .shrink(); // Safeguard against invalid indices
                  }
                  final friend = friends[index];
                  final friendUsername = friend['username'];
                  final friendFirstName = friend['firstName'];

                  return SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friend['profilePicture']),
                        ),
                        title: Text('$friendFirstName ${friend['lastName']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(username: friendUsername),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showRemoveFriendDialog(
                              friendFirstName, friendUsername);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
