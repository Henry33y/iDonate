// ignore_for_file: override_on_non_overriding_member
// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart'; // Import the splash screen
// Updated import
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iDonate',
      theme: ThemeData(
        primaryColor: const Color(0xFFCC2B2B),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFCC2B2B),
          secondary: Color(0xFFCC2B2B),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
