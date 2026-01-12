import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/coin_scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingService = ref.watch(onboardingServiceProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!onboardingService.hasSeenOnboarding &&
          state.uri.path != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          pages: const [
            OnboardingPageModel(
              title: "Identify Coins",
              body: "Snap a photo to instantly identify coins and value.",
              icon: Icons.monetization_on,
            ),
            OnboardingPageModel(
              title: "Track Collection",
              body: "Manage your coin portfolio in one place.",
              icon: Icons.inventory_2,
            ),
            OnboardingPageModel(
              title: "Discover History",
              body: "Learn about the history behind every coin.",
              icon: Icons.history_edu,
            ),
          ],
          onDone: () async {
            await onboardingService.completeOnboarding();
            if (context.mounted) context.go('/');
          },
        ),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'scanner',
            builder: (context, state) => const CoinScannerScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
