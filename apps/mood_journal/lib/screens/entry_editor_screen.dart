import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import '../services/sentiment_service.dart';
import '../services/journal_service.dart';
import '../data/schema.dart';

class EntryEditorScreen extends StatefulWidget {
  const EntryEditorScreen({super.key});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  double _mood = 3.0;
  final TextEditingController _textController = TextEditingController();
  String? _aiFeedback;
  bool _isAnalyzing = false;

  Future<void> _analyze() async {
    if (_textController.text.isEmpty) return;
    setState(() => _isAnalyzing = true);

    final result = await SentimentService().analyze(_textController.text);

    if (mounted) {
      setState(() {
        _aiFeedback = result;
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _save() async {
    final entry = JournalEntry()
      ..date = DateTime.now()
      ..moodScore = _mood.round()
      ..text = _textController.text
      ..sentimentAnalysis = _aiFeedback;

    await JournalService().addEntry(entry);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'New Entry',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mood Slider
            FactoryCard(
              child: Column(
                children: [
                  Text("How are you feeling?",
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("😔", style: TextStyle(fontSize: 24)),
                      Expanded(
                        child: Slider(
                          value: _mood,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _mood.round().toString(),
                          onChanged: (v) => setState(() => _mood = v),
                        ),
                      ),
                      Text("😁", style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Text Input
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // AI Analysis Section
            if (_aiFeedback != null)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        Text("AI Insight",
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(_aiFeedback!,
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyze,
                    icon: _isAnalyzing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.auto_awesome),
                    label: Text("Analyze"),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FactoryButton(
                    label: "Save Journal",
                    onPressed: _save,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
