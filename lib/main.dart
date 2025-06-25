import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:primax_lyalaty_program/screens/splash_screen/splash_screen.dart';

import 'core/utils/constants.dart';
import 'core/utils/navigator_service.dart';
import 'firebase_options.dart';
import 'screens/onboard_screen/onboard_screen.dart';
late SharedPreferences sharedPref;
@pragma('vm:entry-point')
class DownloadCallbackHandler {
  @pragma('vm:entry-point')
  static void callback(String id, int status, int progress) {
    // Handle download progress/status updates here
    final SendPort? send = IsolateNameServer.lookupPortByName('download_isolate');
    if (send != null) {
      send.send([id, status, progress]);
    }
    print("Download task ($id): status=$status, progress=$progress%");
  }
}

Future<void> _initializeFlutterDownloader() async {
  try {
    await FlutterDownloader.initialize(
      debug: true, // Set to false for production
      ignoreSsl: true, // Allow downloads from all sources
    );
    
    // Register the download callback
    FlutterDownloader.registerCallback(DownloadCallbackHandler.callback);
    
    print("Flutter Downloader initialized successfully");
  } catch (e) {
    print("Downloader initialization error: $e");
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  sharedPref = await SharedPreferences.getInstance();
  
  // Initialize Flutter Downloader with proper error handling
  try {
    await _initializeFlutterDownloader();
    print("Flutter Downloader initialized successfully");
  } catch (e) {
    print("Error initializing Flutter Downloader: $e");
  }
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.white, // navigation bar color
  //   statusBarColor: Colors.white, // status bar color
  // ));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(minutes: 0),
  ));

  // try {
  //   print("📡 Fetching Remote Config...");
  //   bool updated = await remoteConfig.fetchAndActivate();
  //   print("✅ Remote Config Updated: $updated");
  //
  //   // 🔍 Print all available keys and values
  //   Map<String, RemoteConfigValue> allValues = remoteConfig.getAll();
  //   print("🔍 All Remote Config Data:");
  //   allValues.forEach((key, value) {
  //     print("➡️ $key: '${value.asString()}'"); // Check if values exist
  //   });
  //
  //   // Print specific keys
  //   String stripePublishKey = remoteConfig.getString("stripe_publish_key");
  //    stripeSecretKey = remoteConfig.getString("stripe_sec_key");
  //
  //   // Stripe.publishableKey = stripePublishKey;
  //
  //   await Stripe.instance.applySettings();
  //   if (stripePublishKey.isEmpty) {
  //     print("⚠️ ERROR: 'stripe_publish_key' is EMPTY.");
  //   }
  //   if (stripeSecretKey.isEmpty) {
  //     print("⚠️ ERROR: 'stripe_sec_key' is EMPTY.");
  //   }
  //
  // } catch (e) {
  //   print("⚠️ ERROR: Remote Config fetch failed: $e");
  // }
  // Initialize Stripe with Publishable Key


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigatorService.navigatorKey,
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

