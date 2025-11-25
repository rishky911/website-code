import 'package:flutter/material.dart';
import 'package:api_connector/api_connector.dart';
import 'package:notification_scheduler/notification_scheduler.dart';
import 'package:ui_shell/ui_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'parcel tracker',
      home: Scaffold(
        appBar: AppBar(title: const Text('parcel_tracker')),
        body: Center(child: Text('Welcome to parcel_tracker')),
      ),
    );
  }
}