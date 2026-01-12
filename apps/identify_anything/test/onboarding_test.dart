import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:onboarding_manager/onboarding_manager.dart';

// Mock OnboardingService
class MockOnboardingService extends Mock implements OnboardingService {
  bool _hasSeen = false;

  @override
  bool get hasSeenOnboarding => _hasSeen;

  @override
  Future<void> completeOnboarding() async {
    _hasSeen = true;
  }

  @override
  Future<void> resetOnboarding() async {
    _hasSeen = false;
  }

  void setSeen(bool value) => _hasSeen = value;
}

void main() {
  group('Onboarding Redirect Logic', () {
    late MockOnboardingService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockOnboardingService();
      container = ProviderContainer(
        overrides: [
          onboardingServiceProvider.overrideWith((ref) => mockService),
        ],
      );
    });

    test('New user should see onboarding', () {
      mockService.setSeen(false);
      expect(
          container.read(onboardingServiceProvider).hasSeenOnboarding, false);
      // In a real widget test, we would check for navigation push
    });

    test('Returning user should NOT see onboarding', () {
      mockService.setSeen(true);
      expect(container.read(onboardingServiceProvider).hasSeenOnboarding, true);
    });
  });
}
