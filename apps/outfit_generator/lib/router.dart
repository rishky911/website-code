import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wardrobe_grid_screen.dart';
import 'screens/generator_screen.dart';

// TODO: Add Onboarding route
// import 'screens/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
