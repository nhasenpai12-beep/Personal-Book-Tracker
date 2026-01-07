import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/model/reading_progress.dart';
import 'package:project_proposal/model/user_settings.dart';
import 'package:project_proposal/model/collection.dart';

class LocalStorageController {
  // Initialize storage directory
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/data');
    
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    // Initialize default settings if not exists
    final settings = await getUserSettings();
    if (settings == null) {
      await saveUserSettings(UserSettings());
    }

    // Load starter books if library is empty
    final books = await getAllBooks();
    if (books.isEmpty) {
      await _loadStarterBooks();
    }
  }

  // ========== BOOKS ==========
  
  Future<void> saveToLocalJSON(Book book) async {
    final books = await getAllBooks();
    books.removeWhere((b) => b.id == book.id);
    books.add(book);
    await _saveBooksToFile(books);
  }

  Future<List<Book>> readFromLocalJSON() async {
    return await getAllBooks();
  }

  Future<List<Book>> getAllBooks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data/books.json');
      
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Book?> getBook(int bookId) async {
    final books = await getAllBooks();
    try {
      return books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteBook(int bookId) async {
    final books = await getAllBooks();
    books.removeWhere((b) => b.id == bookId);
    await _saveBooksToFile(books);
  }

  Future<void> _saveBooksToFile(List<Book> books) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data/books.json');
    final jsonList = books.map((b) => b.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Load starter books from assets
  Future<void> _loadStarterBooks() async {
    final starterBooks = [
      {
        'asset': 'assets/books/alice_wonderland.epub',
        'title': 'Alice\'s Adventures in Wonderland',
        'author': 'Lewis Carroll',
      },
      {
        'asset': 'assets/books/pride_prejudice.epub',
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
      },
      {
        'asset': 'assets/books/sherlock_holmes.epub',
        'title': 'The Adventures of Sherlock Holmes',
        'author': 'Arthur Conan Doyle',
      },
      {
        'asset': 'assets/books/dracula.epub',
        'title': 'Dracula',
        'author': 'Bram Stoker',
      },
      {
        'asset': 'assets/books/frankenstein.epub',
        'title': 'Frankenstein',
        'author': 'Mary Shelley',
      },
    ];

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${appDir.path}/starter_books');
      
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      final allBooks = <Book>[];
      int idCounter = 1;

      for (var bookData in starterBooks) {
        try {
          final assetPath = bookData['asset']!;
          final byteData = await rootBundle.load(assetPath);
          
          final fileName = assetPath.split('/').last;
          final localFile = File('${booksDir.path}/$fileName');
          await localFile.writeAsBytes(byteData.buffer.asUint8List());

          final book = Book(
            id: idCounter++,
            title: bookData['title']!,
            author: bookData['author']!,
            coverPath: '',
            contentPath: localFile.path,
          );

          allBooks.add(book);
          print('✅ Loaded starter book: ${book.title}');
        } catch (e) {
          print('⚠️ Could not load ${bookData['title']}: $e');
        }
      }

      await _saveBooksToFile(allBooks);
    } catch (e) {
      print('⚠️ Error loading starter books: $e');
    }
  }

  // ========== USER SETTINGS ==========
  
  Future<void> saveUserSettings(UserSettings settings) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data/user_settings.json');
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<UserSettings?> getUserSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data/user_settings.json');
      
      if (!await file.exists()) return null;
      
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // ========== READING PROGRESS ==========
  
  Future<void> saveProgress(ReadingProgress progress) async {
    final allProgress = await getAllProgress();
    allProgress.removeWhere((p) => p.bookId == progress.bookId);
    allProgress.add(progress);
    await _saveProgressToFile(allProgress);
  }

  Future<ReadingProgress?> getProgress(int bookId) async {
    final allProgress = await getAllProgress();
    try {
      return allProgress.firstWhere((p) => p.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReadingProgress>> getAllProgress() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data/reading_progress.json');
      
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => ReadingProgress.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveProgressToFile(List<ReadingProgress> progress) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data/reading_progress.json');
    final jsonList = progress.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // ========== COLLECTIONS ==========
  
  Future<void> saveCollection(Collection collection) async {
    final collections = await getAllCollections();
    collections.removeWhere((c) => c.id == collection.id);
    collections.add(collection);
    await _saveCollectionsToFile(collections);
  }

  Future<List<Collection>> getAllCollections() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data/collections.json');
      
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => Collection.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteCollection(int collectionId) async {
    final collections = await getAllCollections();
    collections.removeWhere((c) => c.id == collectionId);
    await _saveCollectionsToFile(collections);
  }

  Future<void> _saveCollectionsToFile(List<Collection> collections) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data/collections.json');
    final jsonList = collections.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
