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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
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
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: TextStyle(
                          color: Colors.white70,
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
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: Color(0xFF8B5CF6),
                        ),
                        title: Text(
                          bookmark.note,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bookmark.chapterTitle != null)
                              Text(
                                bookmark.chapterTitle!,
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
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Color(0xFF8B5CF6)),
                              onPressed: () {
                                // Navigate back to reader at this chapter
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
}
