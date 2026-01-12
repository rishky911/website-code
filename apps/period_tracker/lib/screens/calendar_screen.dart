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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text('Offline Vault',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
      body: Column(
        children: [
          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ],
              ),
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
                  todayDecoration: BoxDecoration(
                      color: FactoryColors.secondary.withValues(alpha: 0.5),
                      shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: FactoryColors.primary, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(
                      color: Colors.red[300], shape: BoxShape.circle),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder: (context, date, event) {
                  // We would need to pass 'eventLoader' to TableCalendar to show dots,
                  // For now, simpler to not show dots or implement a quick loader if feasible.
                  // Skipping dots for MVP speed, relies on clicking day.
                  return null;
                }),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Day Details
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, -4))
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: FactoryColors.primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle),
                              child: Text(DateFormat.d().format(_selectedDay!),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: FactoryColors.primary,
                                      fontSize: 18)),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.MMMM().format(_selectedDay!),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                Text(
                                  DateFormat.EEEE().format(_selectedDay!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        if (_currentEntry != null) ...[
                          _buildDetailRow(Icons.water_drop, 'Flow',
                              _currentEntry!.flowIntensity ?? 'Not recorded'),
                          Divider(height: 32),
                          _buildDetailRow(Icons.notes, 'Note',
                              _currentEntry!.note ?? 'No notes'),
                        ] else
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit_calendar,
                                      size: 48, color: Colors.grey[200]),
                                  SizedBox(height: 8),
                                  Text("No log for this day",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        Spacer(),
                        FactoryButton(
                          label: _currentEntry == null ? 'Log Day' : 'Edit Log',
                          icon: Icons.edit,
                          onPressed: _showEditSheet,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        )
      ],
    );
  }
}

class _EntryEditorSheet extends StatefulWidget {
  final DateTime date;
  final CycleEntry? initialEntry;
  final Function(CycleEntry) onSave;

  const _EntryEditorSheet(
      {required this.date, this.initialEntry, required this.onSave});

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
    // DraggableScrollableSheet for better UX
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Log Details",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _flow,
            decoration: InputDecoration(
              labelText: 'Flow Intensity',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.water_drop, color: Colors.blue),
            ),
            items: ['Light', 'Medium', 'Heavy']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _flow = v!),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Private Notes',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 32),
          FactoryButton(
            label: "Save to Vault",
            icon: Icons.shield,
            onPressed: () {
              final entry = CycleEntry()
                ..date = widget.date
                ..flowIntensity = _flow
                ..note = _noteController.text;

              if (widget.initialEntry != null) {
                entry.id = widget.initialEntry!.id;
              }
              widget.onSave(entry);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
