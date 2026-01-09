import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _key = 'has_seen_onboarding';
  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  bool get hasSeenOnboarding => _prefs.getBool(_key) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_key, true);
  }

  // For debug/reset
  Future<void> resetOnboarding() async {
    await _prefs.remove(_key);
  }
}

// Provider (Initialized in main)
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  throw UnimplementedError('onboardingServiceProvider not initialized');
});
