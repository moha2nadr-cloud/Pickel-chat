import 'dart:io';

class FileReader {
  static Future<String> readFileAsText(String path) async {
    final file = File(path);
    return file.readAsString();
  }
}
