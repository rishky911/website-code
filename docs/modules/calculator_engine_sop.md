# SOP: Calculator Engine

## Purpose
Provides core mathematical functions and specific calculation logic (e.g., currency conversion, rent splitting).

## Inputs
- Raw values (numbers).
- Operation type.

## Outputs
- Calculated result.

## Example Usage
```dart
import 'package:calculator_engine/calculator_engine.dart';

final result = CalculatorEngine.calculateRentSplit(
  total: 1000,
  people: 4,
);
```
