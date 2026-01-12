import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              title: "Scan Anything",
              body: "Instantly identify plants, animals, and coins with AI.",
              icon: Icons.camera_alt,
            ),
            OnboardingPageModel(
              title: "Build Your Collection",
              body: "Save your scans and build a digital museum.",
              icon: Icons.history,
            ),
            OnboardingPageModel(
              title: "Ask Questions",
              body: "Get detailed answers about anything you scan.",
              icon: Icons.chat,
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
            builder: (context, state) => const ScannerScreen(),
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
