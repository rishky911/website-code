import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AffordabilityScreen extends StatefulWidget {
  const AffordabilityScreen({super.key});

  @override
  State<AffordabilityScreen> createState() => _AffordabilityScreenState();
}

class _AffordabilityScreenState extends State<AffordabilityScreen> {
  // Inputs
  double annualIncome = 60000;
  double monthlyDebt = 400;
  double savingsGoal = 500;
  double stateTaxRate = 20;

  // Results
  double conservative = 0;
  double moderate = 0;
  double aggressive = 0;
  double monthlyNet = 0;
  double monthlyTax = 0;

  @override
  void initState() {
    super.initState();
    _calculateAffordability();
  }

  void _calculateAffordability() {
    final monthlyGross = annualIncome / 12;
    monthlyTax = monthlyGross * (stateTaxRate / 100);
    monthlyNet = monthlyGross - monthlyTax;

    // Different Rules
    final rule30PercentGross = monthlyGross * 0.30;

    // Aggressive: 40% of gross
    aggressive = monthlyGross * 0.40;

    // Conservative: 25% gross
    conservative = monthlyGross * 0.25;

    // Moderate: Standard 30% rule adjusted for debt
    // Note: The React logic was: Math.min(rule30PercentGross, monthlyNet - inputs.monthlyDebt - inputs.savingsGoal);
    moderate = (monthlyNet - monthlyDebt - savingsGoal).clamp(
      0,
      rule30PercentGross,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Approximate slate-50
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            _buildResultsSection(),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildQuickTips(),
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
              const Icon(LucideIcons.dollarSign, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Financial Profile',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Annual Gross Income',
            annualIncome,
            (val) => annualIncome = val,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Est. Tax Rate (%)',
                  stateTaxRate,
                  (val) => stateTaxRate = val,
                  isCurrency: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Monthly Debt',
                  monthlyDebt,
                  (val) => monthlyDebt = val,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Monthly Savings Goal',
            savingsGoal,
            (val) => savingsGoal = val,
          ),
          const SizedBox(height: 8),
          Text(
            "We'll subtract this from your available rent budget.",
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    double value,
    Function(double) onChanged, {
    bool isCurrency = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: isCurrency
              ? value.toStringAsFixed(0)
              : value.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: isCurrency ? '\$ ' : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val) ?? 0;
            onChanged(parsed);
            _calculateAffordability();
          },
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildResultCard(
                'Conservative',
                conservative,
                Colors.green,
                'Safe & Saving',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultCard(
                'Recommended',
                moderate,
                Colors.blue,
                'Balanced Life',
                isPrimary: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildResultCard(
          'Max Stretch',
          aggressive,
          Colors.orange,
          'Tight Budget',
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    double amount,
    MaterialColor color,
    String subtitle, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade100, width: isPrimary ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.round()}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: color.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final remaining = (monthlyNet - moderate - monthlyDebt - savingsGoal).clamp(
      0.0,
      double.infinity,
    );

    final data = [
      _ChartData('Rent', moderate, Colors.blue),
      _ChartData('Taxes', monthlyTax, Colors.green),
      _ChartData('Debt/Save', monthlyDebt + savingsGoal, Colors.orange),
      _ChartData('Leftover', remaining, Colors.grey),
    ];

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
          Text(
            'Monthly Budget Breakdown',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlyNet * 1.2, // Add some headroom
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[value.toInt()].name,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: e.value.color,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.checkCircle,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Upfront Cost Estimator',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipRow('First Month', moderate),
          _buildTipRow('Security Deposit', moderate),
          _buildTipRow('Broker Fee (~10%)', moderate * 12 * 0.10),
          const Divider(),
          _buildTipRow(
            'Total Move-in',
            moderate * 2.2 + (moderate * 12 * 0.10),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.blue.shade800,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.round()}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.blue.shade900,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String name;
  final double value;
  final Color color;
  _ChartData(this.name, this.value, this.color);
}
