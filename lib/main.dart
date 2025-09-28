import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:homecare_helper/app_theme.dart';
import 'package:homecare_helper/components/spash_screen.dart';
import 'package:homecare_helper/pages/home_page.dart';
import 'package:homecare_helper/firebase_options.dart';
import 'package:homecare_helper/services/fcm_service.dart';
import 'data/repository/repository.dart';

// Global navigator key để FCM service có thể navigate
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Nhận thông báo trong nền: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Cấu hình xử lý thông báo nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Khởi tạo FCM service với callback để xử lý token
  await FCMService.initialize(
    onTokenReceived: (String token) async {
      print("🎯 Đã nhận FCM Token: $token");

      // TODO: Gửi token lên server của bạn khi user đăng nhập
      // await FCMService.sendTokenToServer(token, userId: 'current_user_id');

      // Subscribe to general topics
      await FCMService.subscribeToTopic('general');
      await FCMService.subscribeToTopic('homecare_updates');
    },
  );

  // Set navigator key cho FCM service
  FCMService.setNavigatorKey(navigatorKey);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HomeCare Helper',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        navigatorKey: navigatorKey,
      ),
    );
  }
}
