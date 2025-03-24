import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homecare_helper/data/model/cost_factor.dart';
import 'package:homecare_helper/data/model/customer.dart';
import 'package:homecare_helper/data/model/helper.dart';
import 'package:homecare_helper/data/model/request.dart';
import 'package:homecare_helper/data/model/request_detail.dart';
import 'package:homecare_helper/data/model/services.dart';
import 'package:homecare_helper/data/repository/repository.dart';
import 'package:homecare_helper/pages/history_page.dart';
import 'package:homecare_helper/pages/home_content.dart';
import 'package:homecare_helper/pages/notification_page.dart';
import 'package:homecare_helper/pages/profile_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;

  const HomePage(
      {super.key,
      required this.customer,
      required this.costFactors,
      required this.services});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  List<Requests> requests = [];
  List<Requests>? requestCustomer = [];
  List<Helper>? helperList = [];
  List<Customer>? customerList = [];
  Timer? _pollingTimer;
  bool isLoading = true; // Thêm biến để theo dõi trạng thái tải dữ liệu

  Future<void> loadHelperData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCleanerData();
    setState(() {
      helperList = data ?? [];
    });
  }

  Future<void> loadRequestData() async {
    var repository = DefaultRepository();
    var data = await repository.loadRequest();
    setState(() {
      requests = data ?? [];
      requestCustomer = requests
          .where((request) =>
              request.customerInfo.fullName == widget.customer.name)
          .toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadRequestData();
    _pages.add(HomeContent(
      // helper: [],
      customers: [widget.customer], // Add the customers parameter
      requests: [
        Requests(
          customerInfo: CustomerInfo(
            fullName: "Nguyễn Văn A",
            phone: "0123456789",
            address: "101 Đường Phạm Ngũ Lão, Quận 1",
            usedPoint: 30,
          ),
          service: RequestService(
            title: "Vệ sinh máy lạnh",
            coefficientService: 1.8,
            coefficientOther: 1.2,
            cost: 350000,
          ),
          location: RequestLocation(
            province: "Hồ Chí Minh",
            district: "Quận 1",
            ward: "Phường Phạm Ngũ Lão",
          ),
          id: "REQ004823",
          oderDate: "2025-03-23",
          scheduleIds: ["SCH006"],
          startTime: "10:00",
          endTime: "12:00",
          requestType: "Đặt lịch",
          totalCost: 630000,
          status: "Chờ xác nhận",
          deleted: false,
          comment: Comment(
            review: "",
            loseThings: false,
            breakThings: false,
          ),
          profit: 210000,
          helperId: null,
          startDate: "2025-03-25",
        ),
      ],
      customer: Customer(
        name: "Nguyễn Văn A",
        phone: "0123456789",
        points: [
          // You might need to create a Point class
          // or use appropriate data structure here
        ],
        email: "nguyenvana@example.com",
        password: "hashedpassword123",
        addresses: [],
      ),
    ));
    _pages.add(HistoryPage());
    _pages.add(NotificationPage());
    _pages.add(ProfilePage());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex.clamp(0, _pages.length - 1)],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          curve: Curves.easeInOut,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              title: const Text("Trang chủ"),
              selectedColor: Colors.green,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.history_rounded),
              title: const Text("Hoạt động"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.notifications_rounded),
              title: const Text("Thông báo"),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_rounded),
              title: const Text("Cá nhân"),
              selectedColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
