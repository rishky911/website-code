library calculator_engine;

class CalculatorEngine {
  double add(double a, double b) => a + b;
  double subtract(double a, double b) => a - b;
  double multiply(double a, double b) => a * b;
  double divide(double a, double b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a / b;
  }

  double convertCurrency(double amount, double rate) {
    return amount * rate;
  }

  Map<String, double> splitBill(
      double total, int people, double tipPercentage) {
    final tipAmount = total * (tipPercentage / 100);
    final totalWithTip = total + tipAmount;
    final perPerson = totalWithTip / people;

    return {
      'total': total,
      'tipAmount': tipAmount,
      'totalWithTip': totalWithTip,
      'perPerson': perPerson,
    };
  }
}
