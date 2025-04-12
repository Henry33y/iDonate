import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Page Coming Soon'),
      ),
    );
  }
} 