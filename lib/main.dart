import 'package:flutter/material.dart';
import 'package:homecare_helper/app_theme.dart';
import 'package:homecare_helper/components/spash_screen.dart';
import 'package:homecare_helper/pages/home_page.dart';

import 'data/repository/repository.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("🔔 Nhận thông báo trong nền: ${message.notification?.title}");
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   String? token = await messaging.getToken();
//   print("📌 FCM Token: $token");
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("📩 Thông báo foreground: ${message.notification?.title}");
//   });
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print("📬 Người dùng bấm vào thông báo: ${message.notification?.title}");
//   });
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: Text('FCM Test')),
//         body: Center(child: Text("FCM đang hoạt động!")),
//       ),
//     );
//   }
// }

void main() {
  runApp(
    // ChangeNotifierProvider(
    // create: (context) => ThemeProvider(),
    const MyApp(),
  );
}

// void main() async{
//   String phone = '0383730311';
//   String fullName = 'Nguyen Van A';
//   String password = '111111';
//   String email = 'trongc71@gmail.com';
//   // Addresses address = Addresses(
//   //   province: 'Hà Nội',
//   //   district: 'Hà Đông',
//   //   ward: 'Phú Lãm',
//   //   detailedAddress: 'Số 123, Đường ABC',
//   // );
//
//   var repository = DefaultRepository();
//   var data = await repository.loginHelper(phone, password);
//   print('Login data: ${data.toString()}');
//   var requestData = await repository.loadCleanerData();
//   print('Request data: ${requestData.toString()}');
//   // var registerData = await repository.registerCustomer(
//   //   '4795335132',
//   //   password,
//   //   fullName,
//   //   email,
//   //   Addresses(
//   //     province: 'Hà Nội',
//   //     district: 'Hà Đông',
//   //     ward: 'Phú Lãm',
//   //     detailedAddress: 'Số 123, Đường ABC',
//   //   ),
//   // );
//   // print('Register data: ${registerData.toString()}');
//   // var customerData = await repository.loadCustomerInfo(data!.user.phone, data.accessToken);
//   // print('Customer data: ${customerData.toString()}');
//   // var requestData = await repository.loadCustomerRequest(data.user.phone, data.accessToken);
//   // print('Request data: ${requestData.toString()}');
//   // var requestDetailData = await repository.loadCustomerRequest(phone, data!.accessToken);
//   // print('Request detail data: ${requestDetailData?.first.schedules}');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: context.watch<ThemeProvider>().themeData,
      home: const SplashScreen(),
      // home: HomePage(),``
    );
  }
}
