import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:project_proposal/model/bookmark.dart';

class BookmarksController {
  Future<void> addBookmark(
    int bookId, 
    int chapterIndex, 
    int paragraphIndex,
    String? chapterTitle, 
    String? previewText,
  ) async {
    final bookmarks = await loadBookmarks(bookId);
    final newId = bookmarks.isEmpty ? 1 : bookmarks.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
    
    final chapterLabel = chapterTitle ?? 'Chapter ${chapterIndex + 1}';
    
    bookmarks.add(Bookmark(
      id: newId,
      bookId: bookId,
      note: 'Bookmark at $chapterLabel',
      chapterIndex: chapterIndex,
      paragraphIndex: paragraphIndex,
      chapterTitle: chapterTitle,
      previewText: previewText,
    ));
    
    await _saveBookmarks(bookId, bookmarks);
  }

  Future<void> removeBookmark(int bookId, int bookmarkId) async {
    final bookmarks = await loadBookmarks(bookId);
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    await _saveBookmarks(bookId, bookmarks);
  }

  Future<List<Bookmark>> loadBookmarks(int bookId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/bookmarks_$bookId.json');
      
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveBookmarks(int bookId, List<Bookmark> bookmarks) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/bookmarks_$bookId.json');
    final jsonList = bookmarks.map((b) => b.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
