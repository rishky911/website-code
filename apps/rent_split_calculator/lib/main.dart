import 'package:flutter/material.dart';
import 'package:calculator_engine/calculator_engine.dart';
import 'package:ui_shell/ui_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rent split calculator',
      home: Scaffold(
        appBar: AppBar(title: const Text('rent_split_calculator')),
        body: Center(child: Text('Welcome to rent_split_calculator')),
      ),
    );
  }
}