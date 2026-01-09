import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reader_screen.dart';

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
          path: 'reader',
          builder: (context, state) => const ReaderScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
