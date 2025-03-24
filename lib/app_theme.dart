import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Định nghĩa màu sắc
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color blue = Colors.blue;

  // 🔤 Cấu hình font chữ
  static const String defaultFontFamily = 'Quicksand';

  // 📌 Theme Light Mode
  static ThemeData lightTheme = ThemeData(
    primaryColor: green,
    scaffoldBackgroundColor: white,
    fontFamily: defaultFontFamily,
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: black),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey[700]),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: green,
      foregroundColor: white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: defaultFontFamily,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // 📌 Theme Dark Mode
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: blue,
    scaffoldBackgroundColor: black,
    fontFamily: defaultFontFamily,
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: white),
      bodySmall: TextStyle(fontSize: 14, color: Colors.grey[400]),
    ),
    appBarTheme: AppBarTheme(backgroundColor: black, foregroundColor: white),
  );
}
