import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smonsg/screens/Home/chat/chat_screen/call_screen/audioCallScreen.dart';
import 'package:smonsg/screens/Home/chat/chat_screen/call_screen/videoCallScreen.dart';
import 'package:smonsg/services/notification_service.dart';
import 'message_database.dart';
import 'message_service.dart';


class FCMNotificationListener extends StatefulWidget {
  final Widget child;

  const FCMNotificationListener({super.key, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _FCMNotificationListenerState createState() => _FCMNotificationListenerState();
}

class _FCMNotificationListenerState extends State<FCMNotificationListener> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final MessageDatabase _messageDatabase = MessageDatabase();
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  void _initializeFCM() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) async {
    try {
      final type = message.data['type'];
      if (type == 'message') {
        _handleIncomingMessage(message.data);
      } else if (type == 'call') {
        _handleIncomingCall(message.data);
      }

      if (message.notification != null) {
        NotificationService().showOverlayNotification(
          context,
          message.notification!.body ?? 'No message body',
          type: type,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling message: $e');
      }
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> data) async {
    final senderUsername = data['senderUsername'] as String?;
    final receiverUsername = data['receiverUsername'] as String?;
    final messageData = data['message'] as String?;

    if (senderUsername != null &&
        receiverUsername != null &&
        messageData != null) {
      try {
        await _messageDatabase.saveMessage(
            senderUsername, receiverUsername, messageData, false);
        await _messageService.acknowledgeMessage();
      } catch (e) {
        if (kDebugMode) {
          print('Error saving message: $e');
        }
      }
    }
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
  final callerUsername = data['callerUsername'] as String?;
  final receiverUsername = data['receiverUsername'] as String?;
  final callType = data['callType'] as String?;
  final agoraToken = data['agoraToken'] as String?;
  final channelName = data['channelName'] as String?;
  final callerUid = int.tryParse(data['callerUid'] ?? '');
  final receiverUid = int.tryParse(data['receiverUid'] ?? '');

  if (kDebugMode) {
    print('Incoming call data - callType: $callType');
    print('callerUsername: $callerUsername');
    print('receiverUsername: $receiverUsername');
    print('agoraToken: $agoraToken');
    print('channelName: $channelName');
    print('callerUid: $callerUid');
    print('receiverUid: $receiverUid');
  }

  if (callerUsername != null &&
      receiverUsername != null &&
      callType != null &&
      agoraToken != null &&
      channelName != null &&
      callerUid != null &&
      receiverUid != null) {
    final route = callType == 'audio'
        ? MaterialPageRoute( 
            builder: (context) => AudioCallScreen(
              username: callerUsername,
              token: agoraToken,
              channelName: channelName,
              callerUid: receiverUid,
              receiverUid: callerUid,
            ),
          )
        : MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              username: callerUsername,
              token: agoraToken,
              channelName: channelName,
              callerUid: receiverUid,
              receiverUid: callerUid,
            ),
          );

    Navigator.push(context, route);
  }
}


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  try {
    final type = message.data['type'];
    if (type == 'message') {
      final senderUsername = message.data['senderUsername'] as String?;
      final receiverUsername = message.data['receiverUsername'] as String?;
      final messageData = message.data['message'] as String?;

      if (senderUsername != null &&
          receiverUsername != null &&
          messageData != null) {
        try {
          final messageDatabase = MessageDatabase();
          await messageDatabase.saveMessage(
              senderUsername, receiverUsername, messageData, false);
          final messageService = MessageService();
          await messageService.acknowledgeMessage();
        } catch (e) {
          if (kDebugMode) {
            print('Error saving message in background: $e');
          }
        }
      }
    }
  // ignore: empty_catches
  } catch (e) {
  }
}
