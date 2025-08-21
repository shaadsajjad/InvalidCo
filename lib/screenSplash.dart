import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Screensplash extends StatelessWidget {
  const Screensplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/images/splashScreen.png")),
    );

    
  }
}
