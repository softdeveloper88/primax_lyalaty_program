import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primax_lyalaty_program/screens/home_screen/home_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/stores_map_screen.dart';

import '../home_screen/news_event_screen.dart';
import '../home_screen/platform_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Default to HomeFragment

  final List<Widget> _screens = [
    HomeScreen(),
    PlatformScreen(),
    StoresMapScreen(),
    NewsEventScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            items: [
              _buildNavItem("assets/icons/home.svg", "Products"),
             // _buildNavItem("assets/icons/calculator.svg", "Calculator"),
              _buildNavItem("assets/icons/platform.svg", "Platform"),
              _buildNavItem("assets/icons/stores.svg", "Stores"),
              _buildNavItem("assets/icons/discover.svg", "Discover"),
            ],
          ),
        ));
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(iconPath, height: 24, color: Colors.grey),
      activeIcon: SvgPicture.asset(iconPath, height: 24, color: Colors.green),
      label: label,
    );
  }
}
