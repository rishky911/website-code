# SOP: Analytics Wrapper

## Purpose
Unified interface for logging events to multiple analytics providers (Firebase, Amplitude).

## Inputs
- Event name.
- Event parameters (Map).

## Outputs
- Void (logs to console in debug).

## Example Usage
```dart
import 'package:analytics_wrapper/analytics_wrapper.dart';

AnalyticsWrapper.logEvent('button_clicked', {'id': 'submit_btn'});
```
