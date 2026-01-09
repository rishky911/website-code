library analytics_wrapper;

import 'package:flutter/foundation.dart';

/// The standard Analytics Engine for the Factory.
/// Acts as a Facade for underlying mechanisms (Firebase, Custom API, etc.).
class AnalyticsWrapper {
  // Singleton instance
  static final AnalyticsWrapper _instance = AnalyticsWrapper._internal();

  factory AnalyticsWrapper() {
    return _instance;
  }

  AnalyticsWrapper._internal();

  /// Log a standard event.
  /// Standard Factory Events: 'app_open', 'feature_used', 'screen_view'
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    debugPrint('[Analytics] Event: $name, Params: $parameters');
    // TODO: Connect to FirebaseAnalytics
    // await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }

  /// Log when a user views a screen.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    debugPrint('[Analytics] Screen View: $screenName');
    await logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        'screen_class': screenClass ?? 'FlutterRoute',
      },
    );
  }

  /// Log user ID (after login).
  Future<void> setUserId(String? id) async {
    debugPrint('[Analytics] Set User ID: $id');
    // await FirebaseAnalytics.instance.setUserId(id: id);
  }
}
