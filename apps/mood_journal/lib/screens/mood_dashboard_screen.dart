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
                  height: 220,
                  padding: EdgeInsets.fromLTRB(12, 24, 24, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true, 
                            interval: 1, 
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == 1) return Text('😔', style: TextStyle(fontSize: 16));
                              if (value == 3) return Text('😐', style: TextStyle(fontSize: 16));
                              if (value == 5) return Text('😁', style: TextStyle(fontSize: 16));
                              return SizedBox.shrink();
                            }
                          )
                        ),
                      ),
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
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: FactoryColors.primary.withOpacity(0.15)),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_entries.isNotEmpty) SizedBox(height: 24),
              
              // Recent Entries
              Text("Recent Logs", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (_entries.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 64),
                      Icon(Icons.auto_awesome, size: 48, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text("Start your journal journey.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
              ..._entries.reversed.map((entry) => Padding( // Show newest first
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            DateFormat.MMMd().add_Hm().format(entry.date),
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                          _buildMoodBadge(entry.moodScore),
                        ],
                      ),
                      if (entry.text != null && entry.text!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(entry.text!, style: TextStyle(fontSize: 15, height: 1.4)),
                      ],
                      if (entry.sentimentAnalysis != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.withOpacity(0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.sentimentAnalysis!,
                                  style: TextStyle(fontSize: 13, color: Colors.purple[800], fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text("$emoji $score/5", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
