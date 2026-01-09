import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:intl/intl.dart';
import '../services/journal_service.dart';
import '../data/schema.dart';
import 'entry_editor_screen.dart';

class MoodDashboardScreen extends StatefulWidget {
  const MoodDashboardScreen({super.key});

  @override
  State<MoodDashboardScreen> createState() => _MoodDashboardScreenState();
}

class _MoodDashboardScreenState extends State<MoodDashboardScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await JournalService().getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Mood Flow',
      floatingActionButton: FloatingActionButton(
        backgroundColor: FactoryColors.primary,
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => EntryEditorScreen()));
          _loadEntries(); // Refresh after return
        },
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Chart Section
              if (_entries.isNotEmpty)
                Container(
                  height: 200,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: _entries.length.toDouble() - 1,
                      minY: 1,
                      maxY: 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _entries.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.moodScore.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: FactoryColors.primary,
                          barWidth: 4,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: FactoryColors.primary.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_entries.isNotEmpty) SizedBox(height: 24),
              
              // Recent Entries
              Text("Recent Logs", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 16),
              if (_entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text("No entries yet. Tap + to start.", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                
              ..._entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FactoryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(entry.date),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildMoodBadge(entry.moodScore),
                        ],
                      ),
                      if (entry.text != null && entry.text!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(entry.text!, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      if (entry.sentimentAnalysis != null) ...[
                        Divider(),
                        Text(
                          "✨ ${entry.sentimentAnalysis}",
                          style: TextStyle(fontSize: 12, color: Colors.purple, fontStyle: FontStyle.italic),
                        ),
                      ]
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
    );
  }

  Widget _buildMoodBadge(int score) {
    Color color;
    String emoji;
    if (score >= 4) {
      color = Colors.green;
      emoji = "😁";
    } else if (score == 3) {
      color = Colors.orange;
      emoji = "😐";
    } else {
      color = Colors.red;
      emoji = "😔";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text("$emoji $score/5", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
