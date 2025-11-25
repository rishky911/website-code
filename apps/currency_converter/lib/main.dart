import 'package:flutter/material.dart';
import 'package:calculator_engine/calculator_engine.dart';
import 'package:api_connector/api_connector.dart';
import 'package:ui_shell/ui_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'currency converter',
      home: Scaffold(
        appBar: AppBar(title: const Text('currency_converter')),
        body: Center(child: Text('Welcome to currency_converter')),
      ),
    );
  }
}