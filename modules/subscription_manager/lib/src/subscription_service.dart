import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Entitlement {
  free,
  pro,
}

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();

  factory SubscriptionService() {
    return _instance;
  }

  SubscriptionService._internal();

  bool _isInitialized = false;
  bool _isDebugMode = true; // Default to true for factory development
  Entitlement _currentEntitlement = Entitlement.free;

  Entitlement get currentEntitlement => _currentEntitlement;
  bool get isPro => _currentEntitlement == Entitlement.pro;

  Future<void> init(String apiKey) async {
    if (_isInitialized) return;

    if (apiKey == "DEBUG_KEY" || kDebugMode) {
      _isDebugMode = true;
      debugPrint(
          "SubscriptionService: Running in DEBUG MODE. No real purchases.");
      _isInitialized = true;
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      await _checkEntitlement();
      _isInitialized = true;
    } catch (e) {
      debugPrint("SubscriptionService Error: $e");
    }
  }

  Future<void> _checkEntitlement() async {
    if (_isDebugMode) return;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateEntitlement(customerInfo);
    } catch (e) {
      debugPrint("Error checking entitlement: $e");
    }
  }

  void _updateEntitlement(CustomerInfo info) {
    if (info.entitlements.all["pro"]?.isActive == true) {
      _currentEntitlement = Entitlement.pro;
    } else {
      _currentEntitlement = Entitlement.free;
    }
    notifyListeners();
  }

  /// Initiates a purchase.
  /// In Debug Mode, this acts as a toggle.
  Future<bool> purchasePro() async {
    if (_isDebugMode) {
      // Simulate successful purchase
      _currentEntitlement = Entitlement.pro;
      notifyListeners();
      return true;
    }

    try {
      // This is assuming we have a package named 'pro_yearly' or similar configured
      // For a generic generic factory, this part gets tricky without real data.
      // So we will stick to fetching offerings.

      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        final package = offerings.current!.availablePackages.first;
        // ignore: deprecated_member_use
        final result = await Purchases.purchasePackage(package);
        final customerInfo = result.customerInfo;
        _updateEntitlement(customerInfo);
        return customerInfo.entitlements.all["pro"]?.isActive ?? false;
      }
      return false;
    } catch (e) {
      debugPrint("Purchase failed: $e");
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (_isDebugMode) {
      _currentEntitlement = Entitlement.pro;
      notifyListeners();
      return;
    }
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updateEntitlement(customerInfo);
    } catch (e) {
      debugPrint("Restore failed: $e");
    }
  }

  // Debug helper
  void resetEntitlement() {
    _currentEntitlement = Entitlement.free;
    notifyListeners();
  }
}

// Riverpod Provider
final subscriptionServiceProvider =
    ChangeNotifierProvider<SubscriptionService>((ref) {
  return SubscriptionService();
});
