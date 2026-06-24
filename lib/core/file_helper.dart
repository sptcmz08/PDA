import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  const FileHelper._();

  static Future<File> createDocumentFile({
    required String fileName,
    required String content,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, fileName));
    return file.writeAsString(content, flush: true);
  }

  static Future<File> createBinaryDocumentFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, fileName));
    return file.writeAsBytes(bytes, flush: true);
  }
}
