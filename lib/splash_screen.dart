import 'package:flutter/material.dart';
import 'dart:async';

// Import the home screen
import 'login.dart'; // Import the first page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds, then go to HomeScreen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your main screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change color as needed
      body: Center(
        child: Text(
  "iDonate",
  style: TextStyle(
    fontSize: MediaQuery.of(context).size.width * 0.07, // ✅ Scales with screen size
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold,
    color: Colors.red,
  ),
),

      ),
    );
  }
}
