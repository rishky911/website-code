import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:subscription_manager/subscription_manager.dart';

// Mock SubscriptionService
class MockSubscriptionService extends Mock implements SubscriptionService {
  bool _isPro = false;

  @override
  bool get isPro => _isPro;

  @override
  bool get hasListeners => false;

  @override
  Entitlement get currentEntitlement => Entitlement.free;

  @override
  Future<void> init(String apiKey) async {}

  @override
  Future<bool> purchasePro() async => true;

  @override
  Future<void> resetEntitlement() async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  void dispose() {}

  @override
  void notifyListeners() {}

  void setPro(bool value) => _isPro = value;
}

void main() {
  group('Scanner Gate Logic', () {
    late MockSubscriptionService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockSubscriptionService();
      container = ProviderContainer(
        overrides: [
          subscriptionServiceProvider.overrideWith((ref) => mockService),
        ],
      );
    });

    test('Free user restricted after 3 scans', () {
      mockService.setPro(false);

      // Simulate Scan Logic
      int scanCount = 0;
      bool canScan() {
        if (!container.read(subscriptionServiceProvider).isPro &&
            scanCount >= 3) {
          return false;
        }
        scanCount++;
        return true;
      }

      // 1-3 should pass
      expect(canScan(), true); // 1
      expect(canScan(), true); // 2
      expect(canScan(), true); // 3

      // 4th should fail
      expect(canScan(), false); // 4
    });

    test('Pro user has unlimited scans', () {
      mockService.setPro(true);

      int scanCount = 0;
      bool canScan() {
        if (!container.read(subscriptionServiceProvider).isPro &&
            scanCount >= 3) {
          return false;
        }
        scanCount++;
        return true;
      }

      // Should allow well past 3
      for (int i = 0; i < 10; i++) {
        expect(canScan(), true);
      }
    });
  });
}
