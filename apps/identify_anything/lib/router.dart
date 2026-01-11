import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Check global provider via context is tricky without consumer
    // We will handle redirect in HomeScreen Init or a specific splash screen?
    // Proper way: Pass a Listenable to GoRouter 'refreshListenable'.
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
        onDone: () => context.go('/'),
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
