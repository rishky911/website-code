import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/eleven_labs_service.dart';
import '../services/audio_player_service.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Voice> _voices = [];
  Voice? _selectedVoice;
  bool _isLoading = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    setState(() => _isLoading = true);
    final voices = await ElevenLabsService().getVoices();
    if (mounted) {
      setState(() {
        _voices = voices;
        if (voices.isNotEmpty) _selectedVoice = voices.first;
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndPlay() async {
    if (_textController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final path = await ElevenLabsService().synthesize(
        _textController.text, 
        _selectedVoice?.id ?? 'demo'
      );

      if (path != null) {
        if (mounted) setState(() => _isLoading = false);
        await AudioPlayerService().playFile(path);
      } else {
         if (mounted) setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate audio')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: 'Settings', onPressed: () {
            // Navigate to settings?
          }),
        ));
      }
    }
  }

  Future<void> _stop() async {
    await AudioPlayerService().stop();
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Voice Studio',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice Selector
            DropdownButtonFormField<Voice>(
              value: _selectedVoice,
              decoration: InputDecoration(
                labelText: 'Select Voice',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _voices.map((v) => DropdownMenuItem(
                value: v,
                child: Text(v.name),
              )).toList(),
              onChanged: (v) => setState(() => _selectedVoice = v),
            ),
            SizedBox(height: 16),
            
            // Text Input
            Expanded(
              child: FactoryCard(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Type something to say...',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Controls
            Row(
              children: [
                Expanded(
                  child: FactoryButton(
                    label: _isLoading ? 'Generating...' : 'Speak',
                    icon: Icons.record_voice_over,
                    isLoading: _isLoading,
                    onPressed: _generateAndPlay,
                  ),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: FactoryColors.error,
                  child: Icon(Icons.stop),
                  onPressed: _stop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
