# SOP: Notification & Scheduler

## Purpose
Manages local notifications and scheduled alarms.

## Inputs
- Notification title and body.
- Schedule time (`DateTime`).

## Outputs
- Scheduled notification ID.

## Example Usage
```dart
import 'package:notification_scheduler/notification_scheduler.dart';

final scheduler = NotificationScheduler();
await scheduler.schedule(
  title: 'Drink Water',
  body: 'Time to hydrate!',
  time: DateTime.now().add(Duration(hours: 1)),
);
```
