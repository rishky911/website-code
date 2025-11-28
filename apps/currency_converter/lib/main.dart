import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:calculator_engine/calculator_engine.dart';
import 'package:api_connector/api_connector.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeEngine.lightTheme,
      darkTheme: ThemeEngine.darkTheme,
      home: const CurrencyConverterHomePage(),
    );
  }
}

class CurrencyConverterHomePage extends StatefulWidget {
  const CurrencyConverterHomePage({super.key});

  @override
  State<CurrencyConverterHomePage> createState() =>
      _CurrencyConverterHomePageState();
}

class _CurrencyConverterHomePageState extends State<CurrencyConverterHomePage> {
  final CalculatorEngine _calculator = CalculatorEngine();
  final ApiConnector _api = ApiConnector();

  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double? _result;
  Map<String, double> _rates = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.get('exchange_rates');
      setState(() {
        _rates = Map<String, double>.from(data['rates']);
        _rates['USD'] = 1.0; // Base
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _convert() {
    if (_amountController.text.isEmpty || _rates.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final fromRate = _rates[_fromCurrency]!;
    final toRate = _rates[_toCurrency]!;

    // Convert to base (USD) then to target
    final amountInUsd = _calculator.divide(amount, fromRate);
    final result = _calculator.convertCurrency(amountInUsd, toRate);

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Currency Converter',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _convert(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromCurrency,
                          items: _rates.keys.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _fromCurrency = value!);
                            _convert();
                          },
                          decoration: const InputDecoration(labelText: 'From'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.arrow_forward),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toCurrency,
                          items: _rates.keys.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _toCurrency = value!);
                            _convert();
                          },
                          decoration: const InputDecoration(labelText: 'To'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (_result != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Result',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_result!.toStringAsFixed(2)} $_toCurrency',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
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
