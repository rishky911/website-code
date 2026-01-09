import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:analytics_wrapper/analytics_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view
    AnalyticsWrapper().logScreenView(screenName: 'HomeScreen');

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
              label: 'Scan Coin',
              icon: Icons.monetIZATION_on, // Or just search
              onPressed: () => context.go('/scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
