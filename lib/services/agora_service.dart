import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class AgoraService {
  late RtcEngine _rtcEngine;

  Future<void> initializeRtcEngine(String appId) async {
    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine.initialize(RtcEngineContext(appId: appId));

    _rtcEngine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (ErrorCodeType errorCode, String? errorMessage) {
          debugPrint('RtcEngine error: $errorCode, message: $errorMessage');
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Join channel success: ${connection.channelId}, uid: ${connection.localUid}');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('Leave channel');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('User joined: $remoteUid');
          setupRemoteVideo(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('User offline: $remoteUid');
        },
      ),
    );

    await _rtcEngine.setDefaultAudioRouteToSpeakerphone(true);
    await _rtcEngine.enableVideo();
  }

  Future<void> joinChannel(String token, String channelName, int uid) async {
    await _rtcEngine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _rtcEngine.leaveChannel();
  }

  Future<void> muteLocalAudioStream(bool mute) async {
    await _rtcEngine.muteLocalAudioStream(mute);
  }

  Future<void> setupRemoteVideo(int uid) async {
    await _rtcEngine.setupRemoteVideo(VideoCanvas(uid: uid));
  }

  Future<void> dispose() async {
    await _rtcEngine.release();
  }

  RtcEngine get rtcEngine => _rtcEngine;
}
