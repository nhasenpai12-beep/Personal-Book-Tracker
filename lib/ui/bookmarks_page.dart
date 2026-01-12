import 'package:flutter/material.dart';
import 'package:project_proposal/data/storage/bookmarks_controller.dart';
import 'package:project_proposal/model/bookmark.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/ui/reader_page.dart';

class BookmarksPage extends StatefulWidget {
  final Book book;

  const BookmarksPage({super.key, required this.book});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksController = BookmarksController();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _bookmarksController.loadBookmarks(widget.book.id);
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  Future<void> _deleteBookmark(int bookmarkId) async {
    await _bookmarksController.removeBookmark(widget.book.id, bookmarkId);
    await _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        title: Text('Bookmarks - ${widget.book.title}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: subtextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: Color(0xFF8B5CF6),
                        ),
                        title: Text(
                          bookmark.note,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter ${bookmark.chapterIndex + 1}${bookmark.chapterTitle != null ? ': ${bookmark.chapterTitle}' : ''}',
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (bookmark.previewText != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                bookmark.previewText!,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(bookmark.createdAt),
                              style: TextStyle(
                                color: subtextColor.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Color(0xFF8B5CF6)),
                              onPressed: () async {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                );
                                
                                // Small delay to ensure smooth transition
                                await Future.delayed(const Duration(milliseconds: 100));
                                
                                if (!mounted) return;
                                
                                // Close loading dialog
                                Navigator.pop(context);
                                
                                // Navigate to reader with the bookmark's chapter
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReaderPage(
                                      book: widget.book,
                                      initialChapterIndex: bookmark.chapterIndex,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'Go to bookmark',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBookmark(bookmark.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
