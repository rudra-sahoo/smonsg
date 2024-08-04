import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smonsg/services/message_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../chat_screen/chats_screen.dart';
import '../../../../../providers/friends_provider.dart';
import 'package:smonsg/services/message_database.dart';
import 'delete_confirmation_dialog.dart';
import 'end_to_end_encryption_info.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final MessageService _messageService = MessageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final MessageDatabase _messageDatabase = MessageDatabase();
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _subscribeToMessageUpdates();
  }

  Future<void> _loadUsers() async {
    final users = await _messageService.getChattedUsers();
    setState(() {
      _users = users;
    });
  }

  void _subscribeToMessageUpdates() {
    _messageService.onNewMessage.listen((newMessage) {
      // Assuming `newMessage` has a structure that includes the sender's username
      final senderUsername = newMessage['senderUsername'];

      if (!_users.contains(senderUsername)) {
        setState(() {
          _users.add(senderUsername);
        });
      }
    });
  }

  Future<void> _deleteChat(String username) async {
    final currentUsername = await _secureStorage.read(key: 'username');
    if (currentUsername != null) {
      await _messageDatabase.deleteChatFile(currentUsername, username);
      setState(() {
        _users.remove(username);
      });
    }
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
          } else if (_users.isEmpty) {
            return const EndToEndEncryptionInfo();
          } else {
            return ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final username = _users[index];
                final friend = friendsProvider.friends.firstWhere(
                  (friend) => friend['username'] == username,
                  orElse: () => null,
                );

                final fullName = friend != null
                    ? '${friend['firstName']} ${friend['lastName']}'
                    : username;

                return GestureDetector(
                  onLongPress: () => showDeleteConfirmationDialog(
                    context,
                    username,
                    fullName,
                    () => _deleteChat(username),
                  ),
                  child: ListTile(
                    leading: friend != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(friend['profilePicture']),
                          )
                        : CircleAvatar(
                            child: Text(username[0].toUpperCase()),
                          ),
                    title: friend != null
                        ? Text('${friend['firstName']}')
                        : Text(username),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(username: username),
                        ),
                      );
                    },
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
