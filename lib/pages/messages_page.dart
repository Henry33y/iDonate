import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text('Messages'),
      ),
      body: const Center(
        child: Text('Messages Page Coming Soon'),
      ),
    );
  }
} 