import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileImportController {
  Future<String?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> copyToLocalStorage(String sourcePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${directory.path}/books');
      
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final fileName = path.basename(sourcePath);
      final targetPath = '${booksDir.path}/$fileName';
      
      final sourceFile = File(sourcePath);
      await sourceFile.copy(targetPath);
      
      return targetPath;
    } catch (e) {
      return null;
    }
  }
}
