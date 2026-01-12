import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:analytics_wrapper/analytics_wrapper.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsWrapper().initialize();
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
      themeMode: ref.watch(themeProvider),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
