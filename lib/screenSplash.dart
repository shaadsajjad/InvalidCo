import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invalidco/permissionPage.dart';
import 'package:invalidco/sample.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final prefs = await SharedPreferences.getInstance();
    bool permitted = prefs.getBool('permitted') ?? false; // default = false

    Timer(const Duration(seconds: 5), () {
      if (permitted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Sample()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Permissionpage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Center(child: Image.asset("assets/images/splashScreen.png")
        )
    );
  }
}