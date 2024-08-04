import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smonsg/screens/Home/chat/chat_screen/call_screen/audioCallScreen.dart';
import 'package:smonsg/screens/Home/chat/chat_screen/call_screen/videoCallScreen.dart';
import 'package:smonsg/services/message_service.dart';
import 'package:smonsg/services/callService.dart';
import 'message_list.dart';
import './bottom_bar/message_input.dart';
import '../../../../providers/friends_provider.dart';

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final CallService _callService;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _callService = CallService(storage: _storage);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await _messageService.getChatsForUser(widget.username);
    setState(() {
      _messages = messages;
    });
  }

  Future<void> _initiateVoiceCall() async {
    try {
      final callDetails = await _callService.initiateCall(widget.username, 'voice');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => AudioCallScreen(
            username: widget.username,
            token: callDetails['agoraToken']!,
            channelName: callDetails['channelName']!,
            callerUid: int.parse(callDetails['callerUid']!),
            receiverUid: int.parse(callDetails['receiverUid']!),
          ),
        ),
      );
    // ignore: empty_catches
    } catch (e) {
    }
  }

  Future<void> _initiateVideoCall() async {
    try {
      final callDetails = await _callService.initiateCall(widget.username, 'video');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            username: widget.username,
            token: callDetails['agoraToken']!,
            channelName: callDetails['channelName']!,
            callerUid: int.parse(callDetails['callerUid']!),
            receiverUid: int.parse(callDetails['receiverUid']!),
          ),
        ),
      );
    // ignore: empty_catches
    } catch (e) {
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _isSending = true;
        _messages.add({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isSentByMe': true,
          'status': 'sending',
        });
      });

      try {
        await _messageService.sendMessage(widget.username, message);
        setState(() {
          _isSending = false;
          _messages.last['status'] = 'delivered';
        });
      } catch (e) {
        setState(() {
          _isSending = false;
          _messages.last['status'] = 'failed';
        });
      }

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final friend = Provider.of<FriendsProvider>(context).friends.firstWhere(
      (friend) => friend['username'] == widget.username,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (friend != null)
              CircleAvatar(
                backgroundImage: NetworkImage(friend['profilePicture']),
              ),
            const SizedBox(width: 8.0),
            Text(friend != null ? friend['firstName'] : widget.username),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _initiateVoiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _initiateVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: MessageList(messages: _messages, isSending: _isSending)),
          MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}
