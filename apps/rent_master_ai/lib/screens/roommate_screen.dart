import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum SplitMethod { equal, income, size }

class Roommate {
  String id;
  String name;
  double income;
  double roomSizeSqFt;

  Roommate({
    required this.id,
    required this.name,
    required this.income,
    required this.roomSizeSqFt,
  });
}

class RoommateScreen extends StatefulWidget {
  const RoommateScreen({super.key});

  @override
  State<RoommateScreen> createState() => _RoommateScreenState();
}

class _RoommateScreenState extends State<RoommateScreen> {
  double totalRent = 3000;
  SplitMethod splitMethod = SplitMethod.income;
  List<Roommate> roommates = [
    Roommate(id: '1', name: 'You', income: 60000, roomSizeSqFt: 150),
    Roommate(id: '2', name: 'Roommate A', income: 50000, roomSizeSqFt: 120),
  ];

  final List<Color> colors = [
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.purple,
  ];

  void _addRoommate() {
    setState(() {
      final newId = (roommates.length + 1).toString();
      roommates.add(
        Roommate(
          id: newId,
          name: 'Roommate ${String.fromCharCode(65 + roommates.length - 1)}',
          income: 45000,
          roomSizeSqFt: 120,
        ),
      );
    });
  }

  void _removeRoommate(String id) {
    if (roommates.length > 1) {
      setState(() {
        roommates.removeWhere((r) => r.id == id);
      });
    }
  }

  List<Map<String, dynamic>> _calculateSplit() {
    double totalFactor = 0;

    if (splitMethod == SplitMethod.equal) {
      final share = totalRent / roommates.length;
      return roommates
          .map(
            (r) => {
              'roommateId': r.id,
              'shareAmount': share,
              'percentage': (1 / roommates.length) * 100,
            },
          )
          .toList();
    }

    if (splitMethod == SplitMethod.income) {
      totalFactor = roommates.fold(0, (sum, r) => sum + r.income);
    } else if (splitMethod == SplitMethod.size) {
      totalFactor = roommates.fold(0, (sum, r) => sum + r.roomSizeSqFt);
    }

    if (totalFactor == 0) return [];

    return roommates.map((r) {
      double factor = splitMethod == SplitMethod.income
          ? r.income
          : r.roomSizeSqFt;
      return {
        'roommateId': r.id,
        'shareAmount': (factor / totalFactor) * totalRent,
        'percentage': (factor / totalFactor) * 100,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculateSplit();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            _buildResultsSection(results),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                'Household Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Total Monthly Rent',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: totalRent.toStringAsFixed(0),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (val) =>
                setState(() => totalRent = double.tryParse(val) ?? 0),
          ),
          const SizedBox(height: 20),
          Text(
            'Split Strategy',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSplitButton('Equal', SplitMethod.equal),
                _buildSplitButton('By Income', SplitMethod.income),
                _buildSplitButton('By Room Size', SplitMethod.size),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Roommates',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: _addRoommate,
                icon: const Icon(LucideIcons.plusCircle, size: 16),
                label: const Text('Add Person'),
              ),
            ],
          ),
          ...roommates.map((r) => _buildRoommateRow(r)),
        ],
      ),
    );
  }

  Widget _buildSplitButton(String label, SplitMethod method) {
    final isSelected = splitMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => splitMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.indigo : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoommateRow(Roommate roommate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: roommate.name,
                  decoration: const InputDecoration.collapsed(hintText: 'Name'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  onChanged: (val) => roommate.name = val,
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: Colors.grey,
                ),
                onPressed: () => _removeRoommate(roommate.id),
              ),
            ],
          ),
          if (splitMethod != SplitMethod.equal) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        splitMethod == SplitMethod.income
                            ? 'Annual Income'
                            : 'Room Sq Ft',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      TextFormField(
                        initialValue: splitMethod == SplitMethod.income
                            ? roommate.income.toString()
                            : roommate.roomSizeSqFt.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: splitMethod == SplitMethod.income
                              ? '\$ '
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            final parsed = double.tryParse(val) ?? 0;
                            if (splitMethod == SplitMethod.income) {
                              roommate.income = parsed;
                            } else {
                              roommate.roomSizeSqFt = parsed;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSection(List<Map<String, dynamic>> results) {
    return Column(
      children: [
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: PieChart(
            PieChartData(
              sections: results.asMap().entries.map((e) {
                final idx = e.key;
                final data = e.value;
                return PieChartSectionData(
                  color: colors[idx % colors.length],
                  value: data['shareAmount'],
                  title: '\$${(data['shareAmount'] as double).round()}',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...results.asMap().entries.map((e) {
          final idx = e.key;
          final res = e.value;
          final mate = roommates.firstWhere((r) => r.id == res['roommateId']);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors[idx % colors.length],
                      radius: 16,
                      child: Text(
                        mate.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mate.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(res['percentage'] as double).toStringAsFixed(1)}% of total',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '\$${(res['shareAmount'] as double).round()}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
