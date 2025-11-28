import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:notification_scheduler/notification_scheduler.dart';

void main() {
  runApp(const WaterReminderApp());
}

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reminder',
      theme: ThemeEngine.lightTheme,
      darkTheme: ThemeEngine.darkTheme,
      home: const WaterReminderHomePage(),
    );
  }
}

class WaterReminderHomePage extends StatefulWidget {
  const WaterReminderHomePage({super.key});

  @override
  State<WaterReminderHomePage> createState() => _WaterReminderHomePageState();
}

class _WaterReminderHomePageState extends State<WaterReminderHomePage> {
  final NotificationScheduler _scheduler = NotificationScheduler();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isScheduled = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _toggleReminder() async {
    if (_isScheduled) {
      await _scheduler.cancelAllNotifications();
      setState(() {
        _isScheduled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminders cancelled')),
        );
      }
    } else {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _scheduler.scheduleNotification(
        title: 'Drink Water!',
        body: 'It\'s time to hydrate.',
        scheduledDate: scheduledDate.isBefore(now)
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate,
      );

      setState(() {
        _isScheduled = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder scheduled!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Water Reminder',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            Text(
              'Reminder Time:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isScheduled ? null : () => _selectTime(context),
              child: Text(
                _selectedTime.format(context),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _toggleReminder,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: Icon(_isScheduled
                  ? Icons.notifications_off
                  : Icons.notifications_active),
              label: Text(_isScheduled ? 'Cancel Reminder' : 'Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
