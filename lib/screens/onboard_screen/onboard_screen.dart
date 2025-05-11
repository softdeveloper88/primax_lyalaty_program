import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/dashboard_screen.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardScreen extends StatefulWidget {
  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'NEXA Series',
      'description': 'Available in 6KW, 8KW, and 12KW. NEXA 12KW is 3-phase hybrid inverter with IP66 Rating are built for high performance, with durability and efficient energy management for various environments.',
      'image': 'assets/images/pic1.png'
    },
    {
      'title': 'GALAXY PV Series',
      'description': 'From 1200W to 12000W, these hybrid single-phase inverters offer reliable solar energy integration and stable power output, perfect for diverse power needs.',
      'image': 'assets/images/pic2.png'
    },
    {
      'title': 'VENUS Series',
      'description': 'Available from 2000W to 10200W, these single-phase hybrid inverters ensure efficient energy backup and high-performance solutions for residential and commercial use.',
      'image': 'assets/images/pic3.png'
    },
  ];

  Future<void> _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding().then((_) {
        // Navigate to the main app or home screen
        DashboardScreen().launch(context,isNewTask: true,pageRouteAnimation: PageRouteAnimation.Fade);
      });
    }
  }

  void _skipOnboarding() {
    _completeOnboarding().then((_) {
      DashboardScreen().launch(context,isNewTask: true,pageRouteAnimation: PageRouteAnimation.Fade);

      // Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Image.asset(_currentPage !=1 ?'assets/images/img_bg.png':'assets/images/img_bg1.png',fit: BoxFit.cover,),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(data['image']!, height: 350,fit: BoxFit.cover,),
                          const SizedBox(height: 20),
                          Text(
                            data['title']!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                    borderRadius: 10,
                      width: double.maxFinite-100,
                      onPressed: _nextPage,
                      text: _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',

                    ),
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16,color: Colors.black38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}