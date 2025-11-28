import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:api_connector/api_connector.dart';
import 'package:notification_scheduler/notification_scheduler.dart';

void main() {
  runApp(const ParcelTrackerApp());
}

class ParcelTrackerApp extends StatelessWidget {
  const ParcelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parcel Tracker',
      theme: ThemeEngine.lightTheme,
      darkTheme: ThemeEngine.darkTheme,
      home: const ParcelTrackerHomePage(),
    );
  }
}

class ParcelTrackerHomePage extends StatefulWidget {
  const ParcelTrackerHomePage({super.key});

  @override
  State<ParcelTrackerHomePage> createState() => _ParcelTrackerHomePageState();
}

class _ParcelTrackerHomePageState extends State<ParcelTrackerHomePage> {
  final ApiConnector _api = ApiConnector();
  final NotificationScheduler _scheduler = NotificationScheduler();
  final TextEditingController _trackingController = TextEditingController();

  String? _status;
  bool _isLoading = false;
  bool _isTracking = false;

  Future<void> _trackParcel() async {
    if (_trackingController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = null;
    });

    try {
      // Mock API call
      await _api.get('tracking/${_trackingController.text}');

      setState(() {
        _status = 'In Transit - Arriving Tomorrow';
        _isTracking = true;
      });

      await _scheduler.scheduleNotification(
        title: 'Parcel Update',
        body: 'Your parcel ${_trackingController.text} is arriving tomorrow!',
        scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
      );
    } catch (e) {
      setState(() => _status = 'Error tracking parcel');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Parcel Tracker',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _trackingController,
              decoration: const InputDecoration(
                labelText: 'Tracking Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _trackParcel,
                child: const Text('Track Parcel'),
              ),
            const SizedBox(height: 40),
            if (_status != null)
              Card(
                color: _isTracking ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isTracking ? Icons.check_circle : Icons.error,
                        color: _isTracking ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _status!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
