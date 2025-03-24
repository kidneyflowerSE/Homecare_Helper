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
  final Helper helper;
  final List<CostFactor> costFactors;
  final List<Services> services;

  const HomePage({
    super.key,
    required this.helper,
    required this.costFactors,
    required this.services,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  List<Requests> requests = [];
  List<Requests>? helperRequests = [];
  List<Customer> customers = [];
  List<RequestDetail> requestDetails = [];
  List<RequestDetail> requestDetailHelper = [];
  bool isLoading = true;

  Future<void> loadRequestData() async {
    try {
      var repository = DefaultRepository();
      var data = await repository.loadRequest();
      setState(() {
        requests = data ?? [];
        helperRequests = requests
            .where((request) => request.helperId == widget.helper.id)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> loadRequestDetailData() async {
  //   var repository = DefaultRepository();
  //   var data =
  //       await repository.getRequestDetailById('66fb6326368eb798fa90aa2f');
  //   setState(() {
  //     requestDetails = data ?? [];
  //     print(data);
  //   });
  // }

  Future<void> loadCustomerData() async {
    try {
      var repository = DefaultRepository();
      var data = await repository.loadCustomer();
      setState(() {
        customers = data ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load customers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadRequestData();
    loadCustomerData();
    // loadRequestDetailData();
    _pages.add(
      HomeContent(
        helper: widget.helper,
        requests: helperRequests ?? [],
        customers: customers,
      ),
    );
    _pages.add(const HistoryPage());
    _pages.add(const NotificationPage());
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _pages[_selectedIndex.clamp(0, _pages.length - 1)],
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
