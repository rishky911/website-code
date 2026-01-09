import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart';
import 'router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FactoryApp(),
    ),
  );
}

class FactoryApp extends ConsumerWidget {
  const FactoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Factory App',
      theme: FactoryTheme.lightTheme,
      darkTheme: FactoryTheme.darkTheme,
      themeMode: ThemeMode.system, // TODO: Connect to settings provider
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
