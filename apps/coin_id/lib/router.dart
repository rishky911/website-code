import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/coin_scanner_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
