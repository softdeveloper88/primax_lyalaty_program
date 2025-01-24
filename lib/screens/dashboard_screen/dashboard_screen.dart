import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primax_lyalaty_program/screens/home_screen/home_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;

  late final List<Widget> _fragments;

  @override
  void initState() {
    // setStatusBarColor(Colors.transparent);
    _fragments = [
      HomeScreen(),
      HomeScreen(),
      HomeScreen(),
      HomeScreen(),
      HomeScreen(),

    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: _fragments[selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        child: BottomNavigationBar(
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          backgroundColor: Colors.white,
          selectedFontSize: 14,
          elevation: 0,
          selectedItemColor: Colors.black,
          unselectedLabelStyle: const TextStyle(color: Colors.grey,fontSize: 12),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500,color: Colors.black),
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildBottomNavigationBarItem('calculator', 'calculator', 'Calculator'),
            _buildBottomNavigationBarItem(
                'platform', 'platform', 'Platform'),
            _buildBottomNavigationBarItem1(
                'home', 'home', ""),
            _buildBottomNavigationBarItem(
                'stores', 'stores', "stores"),
            _buildBottomNavigationBarItem('options', 'options', "Options"),
          ],
          onTap: (val) {

              setState(() => selectedIndex = val);

          },
          currentIndex: selectedIndex,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      String icon, String activeIcon, String label) {
    return BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/$icon.svg',
          height: 24,
          width: 24,
          fit: BoxFit.cover,
        ),
        label: label,
        activeIcon: SvgPicture.asset(
          'assets/icons/$activeIcon.svg',
          height: 26,
          width: 26,
          fit: BoxFit.cover,
        ));
  }
  BottomNavigationBarItem _buildBottomNavigationBarItem1(
      String icon, String activeIcon, String label) {
    return BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/$icon.svg',
          height: 30,
          width: 30,
          fit: BoxFit.cover,
        ),
        label: label,
        activeIcon: SvgPicture.asset(
          'assets/icons/$activeIcon.svg',
          height: 26,
          width: 26,
          fit: BoxFit.cover,
        ));
  }

}
