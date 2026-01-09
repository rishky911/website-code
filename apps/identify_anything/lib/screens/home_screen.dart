import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:analytics_wrapper/analytics_wrapper.dart';
import 'package:onboarding_manager/onboarding_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsWrapper().logScreenView(screenName: 'HomeScreen');

    // Check Onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasSeen = ref.read(onboardingServiceProvider).hasSeenOnboarding;
      if (!hasSeen) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return FactoryScaffold(
      title: 'Factory App',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.go('/settings'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FactoryCard(
              child: Column(
                children: [
                  const Icon(Icons.star, size: 48, color: FactoryColors.tertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to the Factory',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is your BaseApp skeleton. Clone this to start building.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FactoryButton(
              label: 'Primary Action',
              icon: Icons.rocket_launch,
              onPressed: () {
                AnalyticsWrapper().logEvent(name: 'button_clicked', parameters: {'label': 'Primary Action'});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action Triggered!')),
                );
              },
            ),
            const SizedBox(height: 16),
            FactoryButton(
              label: 'Start Scan',
              icon: Icons.camera_alt,
              onPressed: () => context.go('/scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
