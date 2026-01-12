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
  int _currentChapter = 0;
  int _currentParagraph = 0;
  String? _currentChapterTitle;
  String? _currentPreviewText;
  final _readerLogic = ReaderLogic();
  EpubController? _epubController;
  bool _hasNavigatedToInitialChapter = false;

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
      if (widget.initialChapterIndex != null && !_hasNavigatedToInitialChapter) {
        _hasNavigatedToInitialChapter = true;
        // Give the controller more time to fully initialize the document
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Use the controller's jumpTo method with the chapter index
        if (mounted && _epubController != null) {
          try {
            _epubController!.jumpTo(index: widget.initialChapterIndex!);
            print('Jumped to chapter index: ${widget.initialChapterIndex}');
          } catch (e) {
            print('Error jumping to chapter: $e');
          }
        }
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
      final chapterNumber = value.chapterNumber ?? 0;
      final paragraphNumber = value.paragraphNumber ?? 0;
      
      setState(() {
        _currentChapter = chapterNumber;
        _currentParagraph = paragraphNumber;
        _currentChapterTitle = value.chapter?.Title;
        
        // Extract preview text from chapter content
        try {
          final chapterContent = value.chapter?.HtmlContent ?? '';
          // Strip HTML tags and get first 100 characters
          String previewText = chapterContent
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          
          if (previewText.length > 100) {
            previewText = '${previewText.substring(0, 100)}...';
          }
          _currentPreviewText = previewText.isNotEmpty ? previewText : null;
        } catch (e) {
          _currentPreviewText = null;
        }
      });
      
      // Save progress with chapter number
      _readerLogic.saveProgress(widget.book.id, chapterNumber);
      
      print('Chapter changed - Chapter: $chapterNumber, Paragraph: $paragraphNumber');
    }
  }

  Future<void> _addBookmark() async {
    await _readerLogic.addBookmark(
      widget.book.id, 
      _currentChapter,
      _currentParagraph, 
      _currentChapterTitle,
      _currentPreviewText,
    );
    
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        title: Text(widget.book.title, style: TextStyle(fontSize: 18, color: textColor)),
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
                          Text(
                            'Failed to load book',
                            style: TextStyle(color: textColor, fontSize: 18),
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
                        options: DefaultBuilderOptions(
                          textStyle: TextStyle(
                            height: 1.5,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        chapterDividerBuilder: (_) => const Divider(
                          height: 30,
                        ),
                      ),
                    ),
      drawer: _epubController != null
          ? Drawer(
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1E1E1E) 
                  : Colors.white,
              child: EpubViewTableOfContents(
                controller: _epubController!,
              ),
            )
          : null,
    );
  }

  Widget _buildUnsupportedPlatformMessage() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 100, color: subtextColor.withOpacity(0.5)),
            const SizedBox(height: 30),
            Text(
              'EPUB Reader Not Supported',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The EPUB reader is only available on Android and iOS devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtextColor, fontSize: 16),
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
