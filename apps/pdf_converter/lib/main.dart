import 'package:flutter/material.dart';
import 'package:ui_shell/ui_shell.dart';
import 'package:file_processor/file_processor.dart';
import 'package:cross_file/cross_file.dart';

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
  List<XFile> _selectedFiles = [];
  List<String> _history = [];
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
        _history.insert(0,
            'Converted ${_selectedFiles.length} files to ${pdf.name} at ${DateTime.now().toString().split('.')[0]}');
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
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'PDF Converter Pro',
        body: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Convert'),
                Tab(icon: Icon(Icons.history), text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Convert Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedFiles.isNotEmpty)
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.image,
                                          size: 40, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedFiles[index].name,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
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
                            onPressed:
                                _selectedFiles.isNotEmpty ? _convert : null,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Convert to PDF'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // History Tab
                  ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_history[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
