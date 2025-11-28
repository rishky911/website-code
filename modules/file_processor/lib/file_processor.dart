library file_processor;

import 'package:cross_file/cross_file.dart';

class FileProcessor {
  Future<List<XFile>> pickFiles() async {
    // Mock implementation for now
    // In a real app, this would use file_picker package
    await Future.delayed(const Duration(seconds: 1));
    return [XFile('mock_file.txt')];
  }

  Future<XFile> convertToPdf(List<XFile> files) async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
    return XFile('output.pdf');
  }
}
