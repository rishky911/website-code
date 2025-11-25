# SOP: UI Shell / Theme Engine

## Purpose
Provides the common navigation structure, theme management, and settings UI for all apps.

## Inputs
- `ThemeData` configuration (colors, fonts).
- List of `Widget` pages for navigation.

## Outputs
- `MaterialApp` widget with configured theme and routing.

## Example Usage
```dart
import 'package:ui_shell/ui_shell.dart';

void main() {
  runApp(UiShell(
    theme: MyTheme(),
    pages: [HomePage(), SettingsPage()],
  ));
}
```
