import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:io';
import 'package:project_proposal/data/storage/reading_progress_controller.dart';
import 'package:project_proposal/data/storage/bookmarks_controller.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/model/reading_progress.dart';

class ReaderLogic {
  final _progressController = ReadingProgressController();
  final _bookmarksController = BookmarksController();
  
  EpubController? _epubController;
  
  EpubController? get epubController => _epubController;

  Future<EpubController> loadBook(Book book) async {
    final file = File(book.contentPath);
    final bytes = await file.readAsBytes();
    
    // Load saved progress
    final progress = await _progressController.loadProgress(book.id);
    
    _epubController = EpubController(
      document: EpubDocument.openData(bytes),
    );
    
    // Note: Progress restoration can be added later if needed
    // For now, just open the book from the beginning
    
    return _epubController!;
  }

  Future<void> saveProgress(int bookId, int currentChapter) async {
    final progress = ReadingProgress(
      bookId: bookId,
      lastPage: currentChapter,
    );
    await _progressController.saveProgress(progress);
  }

  Future<void> addBookmark(int bookId, int currentChapter, String? chapterTitle, String? previewText) async {
    await _bookmarksController.addBookmark(bookId, currentChapter, chapterTitle, previewText);
  }
  
  void dispose() {
    _epubController?.dispose();
  }
}
