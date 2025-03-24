import 'package:flutter/material.dart';
import 'package:homecare_helper/components/my_button.dart';
import 'package:homecare_helper/components/my_text_field.dart';
import 'package:homecare_helper/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmFocusNode = FocusNode();

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
  );

  String? phoneError;
  String? passwordError;
  String? confirmError;
  bool isLoading = false;
  bool isRegisterSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmFocusNode.dispose();
    super.dispose();
  }

  Future<void> validateAndRegister() async {
    setState(() {
      phoneError = null;
      passwordError = null;
      confirmError = null;
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmController.text.trim();

    bool hasError = false;

    if (phone.isEmpty) {
      setState(() => phoneError = "Số điện thoại không được để trống.");
      hasError = true;
    } else if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      setState(
        () => phoneError =
            "Số điện thoại không hợp lệ. Vui lòng nhập 10 chữ số và bắt đầu bằng số 0.",
      );
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Mật khẩu không được để trống.");
      hasError = true;
    } else if (password.length < 6) {
      setState(() => passwordError = "Mật khẩu phải có ít nhất 6 ký tự.");
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => confirmError = "Vui lòng xác nhận mật khẩu.");
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => confirmError = "Mật khẩu xác nhận không khớp.");
      hasError = true;
    }

    if (!hasError && mounted) {
      // Simulate successful registration
      setState(() => isRegisterSuccess = true);
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigator.push(
      //   context,
      //   PageRouteBuilder(
      //     pageBuilder:
      //         (context, animation, secondaryAnimation) =>
      //             AuthenticationPage(onTap: () {}),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(
      //         opacity: animation,
      //         child: SlideTransition(
      //           position: Tween<Offset>(
      //             begin: const Offset(0, 0.1),
      //             end: Offset.zero,
      //           ).animate(animation),
      //           child: child,
      //         ),
      //       );
      //     },
      //     transitionDuration: const Duration(milliseconds: 500),
      //   ),
      // );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle quicksandStyle = TextStyle(fontFamily: 'Quicksand');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'lib/images/logo.png',
                            width: 180,
                            height: 180,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: const [
                              Text(
                                "Tạo tài khoản mới",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Vui lòng nhập thông tin của bạn",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        MyTextField(
                          controller: phoneController,
                          hintText: "Nhập số điện thoại",
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          errorText: phoneError,
                          focusNode: phoneFocusNode,
                          onChanged: (value) {
                            if (phoneError != null) {
                              setState(() => phoneError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: passwordController,
                          hintText: "Nhập mật khẩu",
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          errorText: passwordError,
                          focusNode: passwordFocusNode,
                          onChanged: (value) {
                            if (passwordError != null) {
                              setState(() => passwordError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: confirmController,
                          hintText: "Xác nhận mật khẩu",
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          errorText: confirmError,
                          focusNode: confirmFocusNode,
                          onChanged: (value) {
                            if (confirmError != null) {
                              setState(() => confirmError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 25),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: MyButton(
                                  text:
                                      isLoading ? "Đang đăng ký..." : "Đăng ký",
                                  onTap: isLoading ? null : validateAndRegister,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: const [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Hoặc",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Đã có tài khoản?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                                child: const Text(
                                  " Đăng nhập",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // if (isLoading)
          //   Container(
          //     color: Colors.black.withOpacity(0.3),
          //     child: Center(
          //       child: Stack(
          //         alignment: Alignment.center,
          //         children: [
          //           AnimatedSwitcher(
          //             duration: const Duration(milliseconds: 500),
          //             child: isRegisterSuccess
          //                 ? Column(
          //                     mainAxisSize: MainAxisSize.min,
          //                     children: [
          //                       Lottie.asset(
          //                         'lib/animations/success.json',
          //                         width: 100,
          //                         height: 100,
          //                         repeat: false,
          //                         errorBuilder: (context, error, stackTrace) {
          //                           return const Icon(
          //                             Icons.check_circle,
          //                             color: Colors.green,
          //                             size: 100,
          //                           );
          //                         },
          //                       ),
          //                       const SizedBox(height: 10),
          //                       const Text(
          //                         "Đăng ký thành công!",
          //                         style: TextStyle(
          //                           fontSize: 18,
          //                           fontWeight: FontWeight.bold,
          //                           color: Colors.white,
          //                         ),
          //                       ),
          //                     ],
          //                   )
          //                 : const CircularProgressIndicator(),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
