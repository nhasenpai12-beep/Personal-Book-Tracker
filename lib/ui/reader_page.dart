import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:project_proposal/data/storage/reader_logic.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/ui/bookmarks_page.dart';
import 'dart:io' show Platform;

class ReaderPage extends StatefulWidget {
  final Book book;
  final int? initialChapterIndex;

  const ReaderPage({super.key, required this.book, this.initialChapterIndex});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _isReaderSupported = false;
  bool _isLoading = true;
  int _currentParagraph = 0;
  String? _currentChapterTitle;
  final _readerLogic = ReaderLogic();
  EpubController? _epubController;

  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
    if (_isReaderSupported) {
      _loadBook();
    }
  }

  void _checkPlatformSupport() {
    _isReaderSupported = Platform.isAndroid || Platform.isIOS;
  }

  Future<void> _loadBook() async {
    try {
      final controller = await _readerLogic.loadBook(widget.book);
      setState(() {
        _epubController = controller;
        _isLoading = false;
      });
      
      // Navigate to initial chapter if specified
      if (widget.initialChapterIndex != null && widget.initialChapterIndex! > 0) {
        // Give the controller time to initialize
        await Future.delayed(const Duration(milliseconds: 500));
        controller.jumpTo(index: widget.initialChapterIndex!);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onChapterChanged(dynamic value) {
    if (value != null) {
      setState(() {
        _currentParagraph = value.chapterNumber ?? 0;
        _currentChapterTitle = value.chapter?.Title;
      });
      _readerLogic.saveProgress(widget.book.id, value.chapterNumber ?? 0);
    }
  }

  Future<void> _addBookmark() async {
    await _readerLogic.addBookmark(widget.book.id, _currentParagraph, _currentChapterTitle);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark added'),
          backgroundColor: Color(0xFF8B5CF6),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
            onPressed: _addBookmark,
            tooltip: 'Add Bookmark',
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
            tooltip: 'View Bookmarks',
          ),
        ],
      ),
      body: !_isReaderSupported
          ? _buildUnsupportedPlatformMessage()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B5CF6),
                  ),
                )
              : _epubController == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 20),
                          const Text(
                            'Failed to load book',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Library'),
                          ),
                        ],
                      ),
                    )
                  : EpubView(
                      controller: _epubController!,
                      onChapterChanged: _onChapterChanged,
                      builders: EpubViewBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(
                          textStyle: TextStyle(
                            height: 1.5,
                            fontSize: 18,
                          ),
                        ),
                        chapterDividerBuilder: (_) => const Divider(
                          height: 30,
                        ),
                      ),
                    ),
      drawer: _epubController != null
          ? Drawer(
              backgroundColor: const Color(0xFF1E1E1E),
              child: EpubViewTableOfContents(
                controller: _epubController!,
              ),
            )
          : null,
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

  @override
  void dispose() {
    _readerLogic.dispose();
    super.dispose();
  }
}
