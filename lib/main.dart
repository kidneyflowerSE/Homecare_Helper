import 'package:flutter/material.dart';
import 'package:homecare_helper/app_theme.dart';
import 'package:homecare_helper/components/spash_screen.dart';
import 'package:homecare_helper/pages/home_page.dart';

import 'data/repository/repository.dart';

void main() {
  runApp(
    // ChangeNotifierProvider(
    // create: (context) => ThemeProvider(),
    const MyApp(),
  );
}

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

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   var repository = DefaultRepository();
//
//   // var request = Requests(
//   //     customerInfo: CustomerInfo(fullName: 'Quốc An Nguyễn',
//   //         phone: '0908123675',
//   //         address: "abc",
//   //         usedPoint: 0),
//   //     service: RequestService(title: "Rửa bát",
//   //         coefficientService: 1.0,
//   //         coefficientOther: 1.0,
//   //         cost: 20000),
//   //     location: RequestLocation(province: 'hcm', district: 'q1', ward: 'p1'),
//   //     id: '',
//   //     oderDate: "2025-03-03",
//   //     scheduleIds: [],
//   //     startTime: "06:00",
//   //     endTime: "10:00",
//   //     requestType: 'Ngắn hạn',
//   //     totalCost: 0,
//   //     status: '',
//   //     deleted: false,
//   //     comment: Comment(review: '', loseThings: false, breakThings: false),
//   //     profit: 0, startDate: "2025-03-03");
//   //
//   // List<String> ids = ['67ca5f695e4280bfc267587d,'];
//
//   // var testCustomer = Customer(addresses: [
//   //   Addresses(
//   //       province: 'Vĩnh Long',
//   //       district: 'Vũng Liêm',
//   //       ward: 'Tân Quới Trung',
//   //       detailedAddress: 'abc')
//   // ], points: [
//   //   Points(point: 100000000, id: '')
//   // ], phone: '0795335321', name: 'Lý Trọng Ân', password: '111111', email: '');
//   // var customers = await repository.loadRequestDetailId([
//   //   '67dbc40c4e2d08a8c2bd5f33',
//   //   '67dbc40c4e2d08a8c2bd5f35',
//   //   '67dbc40c4e2d08a8c2bd5f37',
//   //   '67dbc40c4e2d08a8c2bd5f39',
//   //   '67dbc40c4e2d08a8c2bd5f3b',
//   //   '67dbc40d4e2d08a8c2bd5f3d'
//   // ]);
//
//   var customer = await repository.getRequestDetailById('66fb6326368eb798fa90aa2f');
//   print(customer.toString());
//
//   // var totalCost = await repository.calculateCost(20000,
//   //     request, customers!, 1.1);
//   // print(totalCost);
//   // print(customers?.first.coefficientList.toString());
//
//   // if(customers != null){
//   //   for(var customer in customers){
//   //     debugPrint(customer.toString());
//   //   }
//   // }
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
