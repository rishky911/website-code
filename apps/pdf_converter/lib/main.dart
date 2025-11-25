import 'package:flutter/material.dart';
import 'package:file_processor/file_processor.dart';
import 'package:ui_shell/ui_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pdf converter',
      home: Scaffold(
        appBar: AppBar(title: const Text('pdf_converter')),
        body: Center(child: Text('Welcome to pdf_converter')),
      ),
    );
  }
}