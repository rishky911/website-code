import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:subscription_manager/subscription_manager.dart';
import 'router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'package:analytics_wrapper/analytics_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init RevenueCat
  final subscriptionService = SubscriptionService();
  await subscriptionService.init("sk_hBvxmhjvyQOqPycfDvulkovRHOFSS");

  // Init Onboarding
  final prefs = await SharedPreferences.getInstance();
  final onboardingService = OnboardingService(prefs);

  // Init Analytics
  await AnalyticsWrapper().initialize();

  runApp(
    ProviderScope(
      overrides: [
        subscriptionServiceProvider.overrideWith((ref) => subscriptionService),
        onboardingServiceProvider.overrideWith((ref) => onboardingService),
      ],
      child: const FactoryApp(),
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
