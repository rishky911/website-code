# SOP: API Connector

## Purpose
Handles REST API requests with built-in caching and error handling.

## Inputs
- Endpoint URL.
- HTTP Method (GET, POST, etc.).
- Parameters/Body.

## Outputs
- JSON response data.

## Example Usage
```dart
import 'package:api_connector/api_connector.dart';

final data = await ApiConnector.get('https://api.exchangerate.host/latest');
```
