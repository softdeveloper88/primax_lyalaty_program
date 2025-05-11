import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/dashboard_screen/dashboard_screen.dart';
import 'package:primax_lyalaty_program/screens/home_screen/home_screen.dart';
import 'package:primax_lyalaty_program/screens/login_screen/login_screen.dart';
import 'package:primax_lyalaty_program/screens/onboard_screen/onboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

 @override
  void initState() {

   _checkOnboardingStatus();
    super.initState();
  }
 Future<void> _checkOnboardingStatus() async {
   final SharedPreferences prefs = await SharedPreferences.getInstance();
   final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

   Future.delayed(const Duration(seconds: 2), () {
     if (onboardingComplete) {
       DashboardScreen().launch(context,isNewTask: true,pageRouteAnimation: PageRouteAnimation.Fade);

       // Navigator.pushReplacementNamed(context, '/home');
     } else {
        OnboardScreen().launch(context,isNewTask: true,pageRouteAnimation: PageRouteAnimation.Fade);
       // Navigator.pushReplacementNamed(context, '/onboarding');
     }
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
            child: Image.asset('assets/images/img_splash.png',fit: BoxFit.cover,),
          ),
          Center(child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(30), // Adjust radius as needed

                  child: Image.asset('assets/images/app_logo.png',fit: BoxFit.cover,height: 120,width: 120,)),
              Text('Primax',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,),),
            ],
          )),
          Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(child: Lottie.asset('assets/images/loader.json',height: 200,width: 200,)))
        ],
      ),
    );
  }
}
