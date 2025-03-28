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




  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      HomeContent(
        helper: widget.helper,
      ),
      const HistoryPage(),
      const NotificationPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex.clamp(0, pages.length - 1)],
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
