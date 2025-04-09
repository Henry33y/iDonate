// ignore_for_file: override_on_non_overriding_member
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'splash_screen.dart';  // Import the splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, 
     home: SplashScreen(),
     theme: ThemeData(
      fontFamily: 'Monsterrat'
     )
     );
  }
}
