import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:primax_lyalaty_program/core/utils/navigator_service.dart';
import 'package:primax_lyalaty_program/screens/home_screen/home_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/stores_map_screen.dart';

import '../../main.dart';
import '../home_screen/news_event_screen.dart';
import '../home_screen/platform_screen.dart';
import '../home_screen/widget/drawer_widget.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  final ZoomDrawerController _zoomDrawerController = ZoomDrawerController();

  final List<Widget> _screens = [
    HomeScreen(),
    PlatformScreen(),
    StoresMapScreen(),
    NewsEventScreen(),
  ];

  void _onItemTapped(int index) {

    setState(() {
      _selectedIndex = index;
      _zoomDrawerController.close?.call();

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ZoomDrawer(
        controller: _zoomDrawerController,
        style: DrawerStyle.style2,
        mainScreen: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        mainScreenScale: -0.2,
        menuScreen: DrawerWidget(
          userName: sharedPref.getString('user_name') ?? "",
          profileImageUrl: sharedPref.getString('profile') ?? "",
        ),
        borderRadius: 40.0,
        showShadow: true,
        angle: -12.0,
        mainScreenAbsorbPointer: true,
        slideWidth: MediaQuery.of(context).size.width * .65,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceInOut,
        duration: Duration(milliseconds: 300), // Smooth transition
      ),
      bottomNavigationBar: _isDrawerOpen
          ? SizedBox.shrink() // Hide BottomNavigationBar when drawer is open
          : ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap:_onItemTapped,
            selectedItemColor: Colors.green,
            unselectedItemColor:
          Colors.grey,
          items: [
            _buildNavItem("assets/icons/home.svg", "Products"),
            _buildNavItem("assets/icons/platform.svg", "Platform"),
            _buildNavItem("assets/icons/stores.svg", "Stores"),
            _buildNavItem("assets/icons/discover.svg", "Discover"),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(iconPath, height: 24, color: Colors.grey),
      activeIcon: SvgPicture.asset(iconPath, height: 24, color: Colors.green),
      label: label,
    );
  }
}
