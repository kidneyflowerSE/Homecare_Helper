import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare_helper/components/my_button.dart';
import 'package:homecare_helper/components/my_text_field.dart';
import 'package:homecare_helper/data/model/cost_factor.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/model/services.dart';
import 'package:homecare_helper/data/repository/repository.dart';
import 'package:homecare_helper/pages/home_page.dart';
import 'package:homecare_helper/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Requests> requestsCustomer = [];
  List<Helper> helpers = [];
  List<Requests> requests = [];
  List<Services> services = [];
  List<CostFactor> costFactor = [];
  List<Customer> customers = [];

  String? phoneError;
  String? passwordError;
  bool isLoading = false;
  bool isLoginSuccess = false;

  @override
  void initState() {
    super.initState();
    loadData();
    setupAnimations();
    setupFocusListeners();
  }

  void setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();
  }

  void setupFocusListeners() {
    phoneFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  bool isLoadingData = true;
  Future<void> loadData() async {
    setState(() => isLoadingData = true);
    try {
      var repository = DefaultRepository();
      final customerData = await repository.loadCustomer();
      final requestData = await repository.loadRequest();
      final servicesData = await repository.loadServices();
      final costFactorData = await repository.loadCostFactor();
      final helperData = await repository.loadCleanerData();

      setState(() {
        customers = customerData ?? [];
        requests = requestData ?? [];
        services = servicesData ?? [];
        costFactor = costFactorData ?? [];
        helpers = helperData ?? [];
        // Helper exampleHelper = helpers[0];
        // print("Example: ${exampleHelper.fullName}");
      });
    } finally {
      setState(() => isLoadingData = false);
    }
    print("Data loaded: ${helpers.toString()}");
  }

  String? validatePhone(String value) {
    if (value.isEmpty) {
      return "Số điện thoại không được để trống";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Số điện thoại không hợp lệ. Vui lòng nhập 10 số";
    }
    return null;
  }

  // String? validatePassword(String value) {
  //   if (value.isEmpty) {
  //     return "Mật khẩu không được để trống";
  //   }
  //   return null;
  // }

  // Future<void> login() async {
  //   final phone = phoneController.text.trim();
  //   final password = passwordController.text.trim();

  //   setState(() {
  //     phoneError = validatePhone(phone);
  //     passwordError = validatePassword(password);
  //   });

  //   if (phoneError != null || passwordError != null) return;

  //   setState(() => isLoading = true);

  //   try {
  //     await Future.delayed(
  //         const Duration(seconds: 2)); // Simulate network delay

  //     bool isValid = false;
  //     int customerIndex = 0;

  //     for (int i = 0; i < customers.length; i++) {
  //       if (customers[i].phone == phone && customers[i].password == password) {
  //         isValid = true;
  //         customerIndex = i;
  //         break;
  //       }
  //     }

  //     if (isValid) {
  //       setState(() {
  //         isLoginSuccess = true;
  //       });
  //       requestsCustomer = requests
  //           .where((request) =>
  //               request.customerInfo.fullName == customers[customerIndex].name)
  //           .toList();

  //       // Future.delayed(const Duration(seconds: 1), () {
  //       if (mounted) {
  //         Navigator.pushReplacement(
  //           context,
  //           PageRouteBuilder(
  //             pageBuilder: (context, animation, secondaryAnimation) => HomePage(
  //               customer: customers[customerIndex],
  //               requests: requestsCustomer,
  //               services: services,
  //               costFactor: costFactor,
  //             ),
  //             transitionsBuilder:
  //                 (context, animation, secondaryAnimation, child) {
  //               return FadeTransition(
  //                 opacity: animation,
  //                 child: child,
  //               );
  //             },
  //             transitionDuration: const Duration(milliseconds: 500),
  //           ),
  //         );
  //       }
  //     } else {
  //       setState(
  //           () => passwordError = "Số điện thoại hoặc mật khẩu không đúng");
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => isLoading = false);
  //     }
  //   }
  // }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        // Logo with hero animation
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            'lib/images/logo.png',
                            width: 180,
                            height: 180,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Welcome text
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: Column(
                            children: const [
                              Text(
                                "Chào mừng trở lại!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Hãy đăng nhập để tiếp tục",
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

                        // Phone input
                        MyTextField(
                          controller: phoneController,
                          hintText: "Số điện thoại",
                          obscureText: false,
                          keyboardType: TextInputType.number,
                          errorText: phoneError,
                          focusNode: phoneFocusNode,
                          onChanged: (value) {
                            // if (phoneError != null) {
                            //   setState(() {
                            //     phoneError = validatePhone(value);
                            //   });
                            // }
                          },
                        ),

                        const SizedBox(height: 15),

                        // Password input
                        MyTextField(
                          controller: passwordController,
                          hintText: "Mật khẩu",
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          errorText: passwordError,
                          focusNode: passwordFocusNode,
                          onChanged: (value) {
                            // if (passwordError != null) {
                            //   setState(() {
                            //     passwordError = validatePassword(value);
                            //   });
                            // }
                          },
                        ),

                        const SizedBox(height: 25),

                        // Login button
                        MyButton(
                          text: isLoading ? "Đang đăng nhập..." : "Đăng nhập",
                          // onTap: isLoading ? null : login,
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>  HomePage(

                            //           services: services,
                            //           costFactors: costFactor,
                            //         )));
                          },
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
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
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Chưa có tài khoản?",
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
                                  builder: (context) => const RegisterPage(),
                                ),
                              ),
                              child: const Text(
                                " Đăng ký",
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // if (isLoading)
          //   Container(
          //     color: Colors.black.withOpacity(0.5),
          //     child: Center(
          //       child: Lottie.asset(
          //         'lib/images/loading.json',
          //         width: 200,
          //         height: 200,
          //         repeat: true,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
