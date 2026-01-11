import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/eleven_labs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await ElevenLabsService().getApiKey();
    if (key != null) _apiKeyController.text = key;
  }

  Future<void> _saveKey() async {
    await ElevenLabsService().setApiKey(_apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('API Key Saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FactoryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ElevenLabs Configuration",
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                    helperText: 'Leave empty for Demo Mode',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                FactoryButton(
                  label: "Save Key",
                  onPressed: _saveKey,
                )
              ],
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
