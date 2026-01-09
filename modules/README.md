# 🏭 Module Library (The Parts Bin)

Welcome to the Factory's Parts Bin. These are the standardized LEGO blocks used to assemble apps.

## What makes a valid Module?
1. **Decoupled**: Should not depend on specific apps.
2. **Focused**: Does one thing well (e.g., "Calculate Rent", "Process PDF").
3. **Standard Interface**:
   - `lib/main.dart` or `lib/<module_name>.dart`: Entry point.
   - `pubspec.yaml`: Clearly defined dependencies.

## How to use a Module
Add it to your App's `pubspec.yaml`:

```yaml
dependencies:
  analytics_wrapper:
    path: ../../modules/analytics_wrapper
```

## List of Available Modules
- **analytics_wrapper**: Analytics abstraction layer.
- **api_connector**: Standard HTTP client.
- **calculator_engine**: Core math logic for calculators.
- **file_processor**: File handling utilities.
- **notification_scheduler**: Local notification logic.
- **ui_shell**: Common UI layout wrappers.
