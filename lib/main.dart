import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smonsg/screens/Welcome/welcome_screen.dart';
import 'package:smonsg/screens/Home/home_screen.dart';
import 'package:smonsg/providers/auth_provider.dart';
import 'package:smonsg/providers/qr_code_provider.dart';
import 'package:smonsg/providers/friends_provider.dart';
import 'package:smonsg/services/fcm_notification_listener.dart';
import 'package:smonsg/providers/user_provider.dart';
import 'package:smonsg/services/agora_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  final authProvider = AuthProvider();
  await authProvider.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => QRCodeProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(create: (_) => AgoraService()), // Provide AgoraService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.token != null &&
            authProvider.username != null &&
            authProvider.email != null) {
          return MaterialApp(
            title: 'Real-Time Messaging App',
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.black,
              scaffoldBackgroundColor: Colors.black,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
            ),
            home: FCMNotificationListener(
              child: HomeScreen(
                userName: authProvider.username!,
                email: authProvider.email!,
                token: authProvider.token!,
              ),
            ),
          );
        } else {
          return MaterialApp(
            title: 'Real-Time Messaging App',
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.black,
              scaffoldBackgroundColor: Colors.black,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
            ),
            home: const WelcomeScreen(),
          );
        }
      },
    );
  }
}
