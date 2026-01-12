import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';

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
              title: "Track Cycle",
              body: "Log your period and symptoms accurately.",
              icon: Icons.calendar_today,
            ),
            OnboardingPageModel(
              title: "Predictions",
              body: "Get accurate predictions for your next cycle.",
              icon: Icons.timeline,
            ),
            OnboardingPageModel(
              title: "Health Insights",
              body: "Understand your body better with detailed charts.",
              icon: Icons.monitor_heart,
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
            path: 'calendar',
            builder: (context, state) => const CalendarScreen(),
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
