library analytics_wrapper;

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// The standard Analytics Engine for the Factory.
/// Acts as a Facade for underlying mechanisms (Firebase, Custom API, etc.).
class AnalyticsWrapper {
  // Singleton instance
  static final AnalyticsWrapper _instance = AnalyticsWrapper._internal();

  factory AnalyticsWrapper() {
    return _instance;
  }

  AnalyticsWrapper._internal();

  bool _initialized = false;

  /// Initialize Firebase Core.
  /// Should be called at the start of the app (e.g. main.dart).
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // We attempt to initialize. If google-services.json is missing,
      // this might throw or Log warnings depending on platform.
      // We'll wrap in try-catch to allow app to run without analytics in dev.
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('[Analytics] Firebase Core initialized successfully.');
    } catch (e) {
      debugPrint(
          '[Analytics] WARNING: Firebase initialization failed. Analytics disabled. Error: $e');
    }
  }

  /// Log a standard event.
  /// Standard Factory Events: 'app_open', 'feature_used', 'screen_view'
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    debugPrint('[Analytics] Event: $name, Params: $parameters');
    if (!_initialized) return;
    try {
      await FirebaseAnalytics.instance
          .logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('[Analytics] Failed to log event: $e');
    }
  }

  /// Log when a user views a screen.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    debugPrint('[Analytics] Screen View: $screenName');

    // Log standard screen_view for Firebase
    if (_initialized) {
      try {
        await FirebaseAnalytics.instance.logScreenView(
          screenName: screenName,
          screenClass: screenClass,
        );
      } catch (e) {
        debugPrint('[Analytics] Failed to log screen view: $e');
      }
    }

    // Also custom log
    await logEvent(
      name: 'view_screen_custom',
      parameters: {
        'screen_name': screenName,
        'screen_class': screenClass ?? 'FlutterRoute',
      },
    );
  }

  /// Log user ID (after login).
  Future<void> setUserId(String? id) async {
    debugPrint('[Analytics] Set User ID: $id');
    if (_initialized) {
      await FirebaseAnalytics.instance.setUserId(id: id);
    }
  }
}
