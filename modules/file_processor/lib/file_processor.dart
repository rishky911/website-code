library file_processor;

import 'dart:io';

class FileProcessor {
  Future<List<File>> pickFiles() async {
    // Mock implementation for now
    // In a real app, this would use file_picker package
    await Future.delayed(const Duration(seconds: 1));
    return [File('mock_file.txt')];
  }

  Future<File> convertToPdf(List<File> files) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
    return File('output.pdf');
  }
}
