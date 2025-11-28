import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:file_processor/file_processor.dart';
import 'dart:io';

void main() {
  runApp(const PdfConverterApp());
}

class PdfConverterApp extends StatelessWidget {
  const PdfConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Converter',
      theme: ThemeEngine.lightTheme,
      darkTheme: ThemeEngine.darkTheme,
      home: const PdfConverterHomePage(),
    );
  }
}

class PdfConverterHomePage extends StatefulWidget {
  const PdfConverterHomePage({super.key});

  @override
  State<PdfConverterHomePage> createState() => _PdfConverterHomePageState();
}

class _PdfConverterHomePageState extends State<PdfConverterHomePage> {
  final FileProcessor _fileProcessor = FileProcessor();
  List<File> _selectedFiles = [];
  bool _isConverting = false;
  String? _statusMessage;

  Future<void> _pickFiles() async {
    setState(() {
      _statusMessage = 'Picking files...';
    });
    final files = await _fileProcessor.pickFiles();
    setState(() {
      _selectedFiles = files;
      _statusMessage = 'Selected ${files.length} files';
    });
  }

  Future<void> _convert() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isConverting = true;
      _statusMessage = 'Converting to PDF...';
    });

    try {
      final pdf = await _fileProcessor.convertToPdf(_selectedFiles);
      setState(() {
        _statusMessage = 'Converted to ${pdf.path}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'PDF Converter',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _statusMessage!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            if (_isConverting)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select Files'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _selectedFiles.isNotEmpty ? _convert : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Convert to PDF'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
