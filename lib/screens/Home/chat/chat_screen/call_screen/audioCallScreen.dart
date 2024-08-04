import 'package:flutter/material.dart';
import 'package:smonsg/services/agora_service.dart';

class AudioCallScreen extends StatefulWidget {
  final String username;
  final String token;
  final String channelName;
  final int callerUid;
  final int receiverUid;

  const AudioCallScreen({
    super.key,
    required this.username,
    required this.token,
    required this.channelName,
    required this.callerUid,
    required this.receiverUid,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    await _agoraService.initializeRtcEngine('c56e2c4ea91f41b386ca048f87abef97');
    await _agoraService.joinChannel(widget.token, widget.channelName, widget.callerUid);
  }

  @override
  void dispose() {
    _agoraService.leaveChannel();
    _agoraService.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _agoraService.muteLocalAudioStream(_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        actions: [
          IconButton(
            icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Audio Call with ${widget.username}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
