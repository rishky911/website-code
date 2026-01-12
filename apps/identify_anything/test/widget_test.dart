// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identify_anything/main.dart';
import 'package:subscription_manager/subscription_manager.dart';
import 'package:onboarding_manager/onboarding_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSubscriptionService extends Fake implements SubscriptionService {
  @override
  Future<void> init(String apiKey) async {}
}

class FakeOnboardingService extends Fake implements OnboardingService {
  @override
  bool get hasSeenOnboarding => true;
}

void main() {
  testWidgets('App boots up successfully', (WidgetTester tester) async {
    // Mock SharedPreferences for ThemeProvider
    SharedPreferences.setMockInitialValues({});

    final fakeSub = FakeSubscriptionService();
    final fakeOnboarding = FakeOnboardingService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionServiceProvider.overrideWith((ref) => fakeSub),
          onboardingServiceProvider.overrideWith((ref) => fakeOnboarding),
        ],
        child: const FactoryApp(),
      ),
    );

    // Trigger a frame
    await tester.pumpAndSettle();

    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
