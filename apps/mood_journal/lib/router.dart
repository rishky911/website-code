import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/mood_dashboard_screen.dart';

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
              title: "Track Moods",
              body: "Log your daily moods and identify patterns.",
              icon: Icons.mood,
            ),
            OnboardingPageModel(
              title: "Journaling",
              body: "Write down your thoughts and feelings.",
              icon: Icons.book,
            ),
            OnboardingPageModel(
              title: "Insights",
              body: "Get AI-powered insights into your emotional well-being.",
              icon: Icons.insights,
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
            path: 'dashboard',
            builder: (context, state) => const MoodDashboardScreen(),
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
