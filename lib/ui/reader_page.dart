import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:project_proposal/data/storage/reading_progress_controller.dart';
import 'package:project_proposal/data/storage/bookmarks_controller.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/model/reading_progress.dart';
import 'package:project_proposal/ui/bookmarks_page.dart';
import 'dart:io' show Platform;

class ReaderPage extends StatefulWidget {
  final Book book;

  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _isReaderSupported = false;
  int _currentPage = 0;
  final _progressController = ReadingProgressController();
  final _bookmarksController = BookmarksController();

  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
    if (_isReaderSupported) {
      onStartReading();
    }
  }

  void _checkPlatformSupport() {
    _isReaderSupported = Platform.isAndroid || Platform.isIOS;
  }

  Future<void> onStartReading() async {
    final progress = await _progressController.loadProgress(widget.book.id);
    
    try {
      VocsyEpub.setConfig(
        themeColor: const Color(0xFF8B5CF6),
        identifier: "androidBook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      VocsyEpub.open(
        widget.book.contentPath,
        lastLocation: progress != null 
            ? EpubLocator.fromJson({
                'bookId': widget.book.id,
                'created': DateTime.now().millisecondsSinceEpoch,
                'locations': {},
              })
            : null,
      );

      VocsyEpub.locatorStream.listen((locator) {
        onPageChanged(locator);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void onPageChanged(EpubLocator locator) {
    setState(() {
      _currentPage = DateTime.now().millisecondsSinceEpoch % 10000;
    });
    
    final progress = ReadingProgress(
      bookId: widget.book.id,
      lastPage: _currentPage,
    );
    
    _progressController.saveProgress(progress);
  }

  Future<void> addBookmark() async {
    await _bookmarksController.addBookmark(widget.book.id, _currentPage);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark added'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
    }
  }

  void searchInBook(String query) {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for: $query')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: Text(widget.book.title, style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: addBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarksPage(book: widget.book),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: !_isReaderSupported
          ? _buildUnsupportedPlatformMessage()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reading: ${widget.book.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'by ${widget.book.author}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Current Page: $_currentPage',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUnsupportedPlatformMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_android, size: 100, color: Colors.white38),
            const SizedBox(height: 30),
            const Text(
              'EPUB Reader Not Supported',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The EPUB reader is only available on Android and iOS devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Library'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Search in Book', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter search term',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              searchInBook(controller.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
