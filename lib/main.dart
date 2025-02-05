import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:primax_lyalaty_program/screens/splash_screen/splash_screen.dart';

import 'firebase_options.dart';
import 'screens/onboard_screen/onboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.white, // navigation bar color
  //   statusBarColor: Colors.white, // status bar color
  // ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          //background: linear-gradient(89.99deg, #4AB255 -0.3%, #1EA3D0 85%);
          seedColor: Color(0xFF1EA3D0), // Seed color for generating a palette
          primary: Color(0xFF4AB255), // Main primary color (customized)
          onPrimary: Colors.white, // Text/icon color on primary color
          secondary: Color(0xFF1EA3D0), // Secondary color
          onSecondary: Color(0xFF33384B),
          // Text/icon color on secondary
        ),        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

