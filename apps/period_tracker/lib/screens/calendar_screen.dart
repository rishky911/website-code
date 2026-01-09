import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:intl/intl.dart';
import '../services/privacy_storage_service.dart';
import '../data/schema.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CycleEntry? _currentEntry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEntryForDay(_selectedDay!);
  }

  Future<void> _loadEntryForDay(DateTime day) async {
    setState(() => _isLoading = true);
    final entry = await PrivacyStorageService().getEntryByDate(day);
    if (mounted) {
      setState(() {
        _currentEntry = entry;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEntry(CycleEntry entry) async {
    await PrivacyStorageService().logEntry(entry);
    await _loadEntryForDay(entry.date);
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _EntryEditorSheet(
        date: _selectedDay!,
        initialEntry: _currentEntry,
        onSave: _saveEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Cycle Tracker',
      actions: [
        // Privacy Badge
        Container(
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, size: 12, color: Colors.green),
              SizedBox(width: 4),
              Text('Encrypted', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
      body: Column(
        children: [
          // Calendar
          FactoryCard(
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadEntryForDay(selectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: FactoryColors.secondary.withOpacity(0.5), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: FactoryColors.primary, shape: BoxShape.circle),
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Day Details
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(_selectedDay!),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      if (_currentEntry != null) ...[
                        _buildDetailCard('Flow', _currentEntry!.flowIntensity ?? 'Not recorded'),
                        SizedBox(height: 8),
                        _buildDetailCard('Note', _currentEntry!.note ?? 'No notes'),
                      ] else
                        Center(child: Text("No data for this day", style: TextStyle(color: Colors.grey))),
                      Spacer(),
                      FactoryButton(
                        label: _currentEntry == null ? 'Log Day' : 'Edit Log',
                        icon: Icons.edit,
                        onPressed: _showEditSheet,
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
          Text(value),
        ],
      ),
    );
  }
}

class _EntryEditorSheet extends StatefulWidget {
  final DateTime date;
  final CycleEntry? initialEntry;
  final Function(CycleEntry) onSave;

  const _EntryEditorSheet({required this.date, this.initialEntry, required this.onSave});

  @override
  State<_EntryEditorSheet> createState() => _EntryEditorSheetState();
}

class _EntryEditorSheetState extends State<_EntryEditorSheet> {
  String _flow = 'Medium';
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      _flow = widget.initialEntry!.flowIntensity ?? 'Medium';
      _noteController.text = widget.initialEntry!.note ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Log Details", style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _flow,
              decoration: InputDecoration(labelText: 'Flow Intensity'),
              items: ['Light', 'Medium', 'Heavy'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _flow = v!),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            FactoryButton(
              label: "Save (Encrypted)",
              icon: Icons.lock,
              onPressed: () {
                final entry = CycleEntry()
                  ..date = widget.date
                  ..flowIntensity = _flow
                  ..note = _noteController.text;
                // If editing existing, we'd preserve ID, but Isar handles IDs internally on put usually.
                // For simplicity assuming new object overwrites logic or we'd copy ID.
                if (widget.initialEntry != null) {
                   entry.id = widget.initialEntry!.id;
                }
                widget.onSave(entry);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
