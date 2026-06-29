import 'package:flutter/material.dart';

/// Home screen displayed after successful authentication.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatAeron'), centerTitle: true),
      body: const Center(
        child: Text(
          'Welcome to ChatAeron 🚀',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
