import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:epubx/epubx.dart';
import 'package:image/image.dart' as img;

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

  Future<Map<String, dynamic>> extractMetadata(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final book = await EpubReader.readBook(bytes);
      
      String title = book.Title ?? path.basenameWithoutExtension(filePath);
      String author = book.Author ?? 'Unknown Author';
      String? coverImagePath;
      
      // Extract cover image
      if (book.CoverImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final coversDir = Directory('${directory.path}/covers');
        
        if (!await coversDir.exists()) {
          await coversDir.create(recursive: true);
        }
        
        final coverFileName = '${DateTime.now().millisecondsSinceEpoch}_cover.png';
        final coverPath = '${coversDir.path}/$coverFileName';
        final coverFile = File(coverPath);
        
        // Encode the Image to PNG bytes
        final pngBytes = img.encodePng(book.CoverImage!);
        await coverFile.writeAsBytes(pngBytes);
        coverImagePath = coverPath;
      }
      
      return {
        'title': title,
        'author': author,
        'coverPath': coverImagePath ?? '',
      };
    } catch (e) {
      return {
        'title': path.basenameWithoutExtension(filePath),
        'author': 'Unknown Author',
        'coverPath': '',
      };
    }
  }
}
