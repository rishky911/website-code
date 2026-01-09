import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (val) {
                // TODO: Wire up with Riverpod ThemeProvider
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
