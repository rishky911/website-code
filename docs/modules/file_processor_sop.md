# SOP: File Processor

## Purpose
Handles file selection, format conversion (e.g., Image to PDF), and file sharing.

## Inputs
- Source file path.
- Target format.

## Outputs
- Processed file path.
- Success/Failure status.

## Example Usage
```dart
import 'package:file_processor/file_processor.dart';

final processor = FileProcessor();
await processor.convert(source: 'image.png', target: 'doc.pdf');
```
