import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _currentToken;
  static Function(String)? _onTokenReceived;
  static GlobalKey<NavigatorState>? _navigatorKey;

  // Getter để lấy token hiện tại
  static String? get currentToken => _currentToken;

  // Set navigator key để có thể navigate
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // Khởi tạo FCM service
  static Future<void> initialize({Function(String)? onTokenReceived}) async {
    _onTokenReceived = onTokenReceived;

    // Yêu cầu quyền thông báo
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Người dùng đã cấp quyền thông báo');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Người dùng đã cấp quyền thông báo tạm thời');
    } else {
      print('❌ Người dùng từ chối quyền thông báo');
    }

    // Lấy FCM token và lưu trữ
    await _getAndStoreToken();

    // Lắng nghe thông báo khi app đang mở
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

    // Lắng nghe khi người dùng tap vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

    // Kiểm tra thông báo đã mở app (khi app đã tắt hoàn toàn)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage);
    }

    // Lắng nghe token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      _saveTokenToPrefs(newToken);
      print("🔄 Token đã được refresh: $newToken");
      if (_onTokenReceived != null) {
        _onTokenReceived!(newToken);
      }
    });
  }

  // Lấy và lưu trữ token
  static Future<void> _getAndStoreToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _saveTokenToPrefs(token);
        print("📌 FCM Token: $token");
        if (_onTokenReceived != null) {
          _onTokenReceived!(token);
        }
      }
    } catch (e) {
      print('❌ Lỗi khi lấy FCM token: $e');
    }
  }

  // Lưu token vào SharedPreferences
  static Future<void> _saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('❌ Lỗi khi lưu token: $e');
    }
  }

  // Lấy token từ SharedPreferences
  static Future<String?> getTokenFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ Lỗi khi lấy token từ prefs: $e');
      return null;
    }
  }

  // Lấy FCM token
  static Future<String?> getToken() async {
    if (_currentToken != null) {
      return _currentToken;
    }

    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _saveTokenToPrefs(token);
      }
      return token;
    } catch (e) {
      print('❌ Lỗi khi lấy FCM token: $e');
      return null;
    }
  }

  // Send token to server
  static Future<void> sendTokenToServer(String token, {String? userId}) async {
    try {
      // TODO: Implement API call to send token to your server
      print('🚀 Gửi token lên server: $token');
      // Example:
      // await http.post(
      //   Uri.parse('your-api-endpoint/fcm-token'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'token': token, 'userId': userId}),
      // );
    } catch (e) {
      print('❌ Lỗi khi gửi token lên server: $e');
    }
  }

  // Refresh FCM token
  static Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      String? newToken = await _firebaseMessaging.getToken();
      if (newToken != null) {
        _currentToken = newToken;
        await _saveTokenToPrefs(newToken);
        print("🔄 Token mới: $newToken");
        if (_onTokenReceived != null) {
          _onTokenReceived!(newToken);
        }
      }
      return newToken;
    } catch (e) {
      print('❌ Lỗi khi refresh token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Đã subscribe topic: $topic');
    } catch (e) {
      print('❌ Lỗi khi subscribe topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Đã unsubscribe topic: $topic');
    } catch (e) {
      print('❌ Lỗi khi unsubscribe topic $topic: $e');
    }
  }

  // Xử lý thông báo khi app đang mở
  static void handleForegroundMessage(RemoteMessage message) {
    print("📩 Thông báo foreground: ${message.notification?.title}");

    // Hiển thị thông báo overlay
    if (message.notification != null) {
      showSimpleNotification(
        Text(message.notification!.title ?? 'Thông báo'),
        subtitle: Text(message.notification!.body ?? ''),
        background: Colors.blue,
        duration: Duration(seconds: 4),
        leading: Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        trailing: TextButton(
          onPressed: () {
            // Dismiss the notification overlay
            if (_navigatorKey?.currentContext != null) {
              OverlaySupportEntry.of(_navigatorKey!.currentContext!)?.dismiss();
            }
            _handleDataPayload(message.data);
          },
          child: Text(
            'Xem',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Xử lý data payload nếu có
    if (message.data.isNotEmpty) {
      print("📊 Data payload: ${message.data}");
    }
  }

  // Xử lý khi người dùng tap vào thông báo
  static void handleNotificationTap(RemoteMessage message) {
    print("📬 Người dùng bấm vào thông báo: ${message.notification?.title}");

    // Xử lý navigation hoặc action dựa trên data
    if (message.data.isNotEmpty) {
      _handleDataPayload(message.data);
    }
  }

  // Xử lý data payload
  static void _handleDataPayload(Map<String, dynamic> data) {
    if (_navigatorKey?.currentContext == null) return;

    // Ví dụ xử lý các loại thông báo khác nhau
    String? type = data['type'];
    String? targetScreen = data['screen'];

    switch (type) {
      case 'booking':
        print('🏠 Thông báo booking mới');
        // Navigate to booking screen
        // _navigatorKey!.currentState?.pushNamed('/booking');
        break;
      case 'message':
        print('💬 Tin nhắn mới');
        // Navigate to chat screen
        // _navigatorKey!.currentState?.pushNamed('/chat');
        break;
      case 'reminder':
        print('⏰ Nhắc nhở');
        // Show reminder dialog
        _showReminderDialog(data);
        break;
      case 'update':
        print('🔄 Cập nhật ứng dụng');
        // Show update dialog
        break;
      default:
        print('📋 Thông báo chung: $data');
        break;
    }
  }

  // Hiển thị dialog nhắc nhở
  static void _showReminderDialog(Map<String, dynamic> data) {
    if (_navigatorKey?.currentContext == null) return;

    showDialog(
      context: _navigatorKey!.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Nhắc nhở'),
        content: Text(data['message'] ?? 'Bạn có một nhắc nhở mới'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
          if (data['action'] != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Xử lý action
              },
              child: Text('Xem chi tiết'),
            ),
        ],
      ),
    );
  }

  // Clear token (logout)
  static Future<void> clearToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('🗑️ Đã xóa FCM token');
    } catch (e) {
      print('❌ Lỗi khi xóa token: $e');
    }
  }
}
