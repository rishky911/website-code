import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/eleven_labs_service.dart';
import '../services/audio_player_service.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Voice> _voices = [];
  Voice? _selectedVoice;
  bool _isLoading = false;

  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _loadVoices();
    _visualizerController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000))
          ..repeat();
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
      final path = await ElevenLabsService()
          .synthesize(_textController.text, _selectedVoice?.id ?? 'demo');

      if (mounted) setState(() => _isLoading = false);

      if (path != null) {
        await AudioPlayerService().playFile(path);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to generate audio')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    super.dispose();
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Voice>(
                  value: _selectedVoice,
                  hint: Text('Select Voice'),
                  isExpanded: true,
                  items: _voices
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    color: FactoryColors.primary),
                                SizedBox(width: 8),
                                Text(v.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVoice = v),
                ),
              ),
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

            // Visualizer & Controls
            StreamBuilder(
                // TODO: Fix type
                stream: AudioPlayerService().playerStateStream,
                builder: (context, snapshot) {
                  // final playerState = snapshot.data;
                  // final isPlaying = playerState?.playing ?? false;
                  // We don't have PlayerState type import easily without just_audio,
                  // checking AudioPlayerService.isPlaying in a loop or assumed state.
                  // Simpler: Just rely on local isPlaying wrapper if we had one, but better to trust the future.
                  // Actually, let's just use the stream to trigger rebuilds.
                  final isPlaying = AudioPlayerService().isPlaying;

                  return Column(
                    children: [
                      if (isPlaying)
                        SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                10,
                                (index) =>
                                    _buildBar(index, _visualizerController)),
                          ),
                        )
                      else
                        SizedBox(height: 48),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FactoryButton(
                              label: _isLoading
                                  ? 'Generating...'
                                  : (isPlaying ? 'Playing...' : 'Speak'),
                              icon: isPlaying
                                  ? Icons.volume_up
                                  : Icons.record_voice_over,
                              isLoading: _isLoading,
                              onPressed:
                                  isPlaying ? null : () => _generateAndPlay(),
                            ),
                          ),
                          if (isPlaying) ...[
                            SizedBox(width: 16),
                            FloatingActionButton(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.stop),
                              onPressed: () => AudioPlayerService().stop(),
                            ),
                          ]
                        ],
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(int index, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Random-ish height based on sine wave with offset
        final height = 10 +
            30 * (0.5 + 0.5 * sin(controller.value * 2 * 3.14 + index)).abs();
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: height,
          decoration: BoxDecoration(
            color: FactoryColors.secondary,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
