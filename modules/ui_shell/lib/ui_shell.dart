library ui_shell;

import 'package:flutter/material.dart';

class ThemeEngine {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      useMaterial3: true,
    );
  }
}

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
