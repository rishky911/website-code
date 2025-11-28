import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:calculator_engine/calculator_engine.dart';

void main() {
  runApp(const RentSplitCalculatorApp());
}

class RentSplitCalculatorApp extends StatelessWidget {
  const RentSplitCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Split Calculator',
      theme: ThemeEngine.lightTheme,
      darkTheme: ThemeEngine.darkTheme,
      home: const RentSplitHomePage(),
    );
  }
}

class RentSplitHomePage extends StatefulWidget {
  const RentSplitHomePage({super.key});

  @override
  State<RentSplitHomePage> createState() => _RentSplitHomePageState();
}

class _RentSplitHomePageState extends State<RentSplitHomePage> {
  final CalculatorEngine _calculator = CalculatorEngine();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  Map<String, double>? _result;

  void _calculate() {
    final total = double.tryParse(_totalController.text);
    final people = int.tryParse(_peopleController.text);

    if (total != null && people != null && people > 0) {
      setState(() {
        _result = _calculator.splitBill(total, people, 0); // 0% tip for rent
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rent Split Calculator',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Rent',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate Split'),
            ),
            const SizedBox(height: 40),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Per Person',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_result!['perPerson']!.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
