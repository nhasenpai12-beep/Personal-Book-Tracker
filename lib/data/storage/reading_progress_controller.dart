import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:project_proposal/model/reading_progress.dart';

class ReadingProgressController {
  Future<void> saveProgress(ReadingProgress progress) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reading_progress_${progress.bookId}.json');
    await file.writeAsString(jsonEncode(progress.toJson()));
  }

  Future<ReadingProgress?> loadProgress(int bookId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reading_progress_$bookId.json');
      
      if (!await file.exists()) return null;
      
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return ReadingProgress.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
