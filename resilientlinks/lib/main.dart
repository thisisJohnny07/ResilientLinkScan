import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinks/firebase_options.dart';
import 'package:resilientlinks/home_page.dart';
import 'package:resilientlinks/verification.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkVerificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the user is verified
    return prefs.getBool('isVerified') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkVerificationStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking status
          return const CircularProgressIndicator();
        } else {
          // Based on verification status, return the appropriate home
          if (snapshot.data == true) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: HomePage(),
            );
          } else {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Verification(),
            );
          }
        }
      },
    );
  }
}
