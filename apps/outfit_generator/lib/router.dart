import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wardrobe_grid_screen.dart';
import 'screens/generator_screen.dart';

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
              title: "Digital Wardrobe",
              body: "Digitize your closet by snapping photos.",
              icon: Icons.checkroom,
            ),
            OnboardingPageModel(
              title: "Outfit Ideas",
              body: "Get daily outfit suggestions based on weather and style.",
              icon: Icons.lightbulb,
            ),
            OnboardingPageModel(
              title: "Style Assistant",
              body: "Ask for advice on what to wear for any occasion.",
              icon: Icons.face_retouching_natural,
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
            path: 'wardrobe',
            builder: (context, state) => const WardrobeGridScreen(),
          ),
          GoRoute(
            path: 'generator',
            builder: (context, state) => const GeneratorScreen(),
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
