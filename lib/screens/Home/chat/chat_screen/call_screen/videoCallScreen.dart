import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:smonsg/services/agora_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String username;
  final String token;
  final String channelName;
  final int callerUid;
  final int receiverUid;

  const VideoCallScreen({
    super.key,
    required this.username,
    required this.token,
    required this.channelName,
    required this.callerUid,
    required this.receiverUid,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    try {
      await _agoraService.initializeRtcEngine('c56e2c4ea91f41b386ca048f87abef97');
      await _agoraService.joinChannel(widget.token, widget.channelName, widget.callerUid);
      // Adding video setup for both users
      _setupVideo();
    // ignore: empty_catches
    } catch (e) {
    }
  }

  void _setupVideo() {
    try {
      _agoraService.rtcEngine.setupRemoteVideo(
        VideoCanvas(
          uid: widget.receiverUid,
        ),
      );
    // ignore: empty_catches
    } catch (e) {
    }

    try {
      _agoraService.rtcEngine.setupLocalVideo(
        VideoCanvas(
          uid: widget.callerUid,
        ),
      );
    // ignore: empty_catches
    } catch (e) {
    }
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
      body: Stack(
        children: [
          // Remote user video
          Align(
            alignment: Alignment.center,
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _agoraService.rtcEngine,
                canvas: VideoCanvas(uid: widget.receiverUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            ),
          ),
          // Local user video
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _agoraService.rtcEngine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
