import 'package:flutter/material.dart';
import 'package:homecare_helper/app_theme.dart';
import 'package:homecare_helper/components/spash_screen.dart';
import 'package:homecare_helper/pages/home_page.dart';

void main() {
  runApp(
    // ChangeNotifierProvider(
    // create: (context) => ThemeProvider(),
    const MyApp(),
  );
}

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
