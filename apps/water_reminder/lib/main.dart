import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'water reminder',
      home: Scaffold(
        appBar: AppBar(title: const Text('water_reminder')),
        body: Center(child: Text('Welcome to water_reminder')),
      ),
    );
  }
}
