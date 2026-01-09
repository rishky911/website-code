import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';

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
