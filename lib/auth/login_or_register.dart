import 'package:flutter/material.dart';
import 'package:homecare_helper/pages/login_page.dart';
import 'package:homecare_helper/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Initially show the login page
  bool showLoginPage = true;

  // Toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage
          ? LoginPage(
              key: const ValueKey('LoginPage'),
              onTap: togglePages,
            )
          : LoginPage(
              key: const ValueKey('RegisterPage'),
              onTap: togglePages,
            ),
    );
  }
}
