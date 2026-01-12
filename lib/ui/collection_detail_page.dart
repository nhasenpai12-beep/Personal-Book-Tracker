import 'package:flutter/material.dart';
import 'package:project_proposal/data/storage/local_storage_controller.dart';
import 'package:project_proposal/model/collection.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/ui/reader_page.dart';
import 'dart:io';

class CollectionDetailPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailPage({super.key, required this.collection});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  final _storage = LocalStorageController();
  List<Book> _booksInCollection = [];
  List<Book> _allBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final allBooks = await _storage.getAllBooks();
    final booksInCollection = allBooks
        .where((book) => widget.collection.bookIds.contains(book.id))
        .toList();
    
    setState(() {
      _allBooks = allBooks;
      _booksInCollection = booksInCollection;
      _isLoading = false;
    });
  }

  Future<void> _addBooksToCollection() async {
    final availableBooks = _allBooks
        .where((book) => !widget.collection.bookIds.contains(book.id))
        .toList();

    if (availableBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All books are already in this collection'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
      return;
    }

    final selectedBooks = await showDialog<List<int>>(
      context: context,
      builder: (context) => _AddBooksDialog(availableBooks: availableBooks),
    );

    if (selectedBooks != null && selectedBooks.isNotEmpty) {
      final updatedCollection = widget.collection.copyWith(
        bookIds: [...widget.collection.bookIds, ...selectedBooks],
      );
      await _storage.saveCollection(updatedCollection);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${selectedBooks.length} book(s) to collection'),
            backgroundColor: const Color(0xFF8B5CF6),
          ),
        );
      }
    }
  }

  Future<void> _removeBookFromCollection(int bookId) async {
    final updatedCollection = widget.collection.copyWith(
      bookIds: widget.collection.bookIds.where((id) => id != bookId).toList(),
    );
    await _storage.saveCollection(updatedCollection);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book removed from collection'),
          backgroundColor: Color(0xFF8B5CF6),
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
        title: Text(widget.collection.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addBooksToCollection,
            tooltip: 'Add books',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _booksInCollection.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.library_books,
                        size: 64,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No books in this collection',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addBooksToCollection,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Books'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _booksInCollection.length,
                  itemBuilder: (context, index) {
                    final book = _booksInCollection[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderPage(book: book),
                          ),
                        );
                      },
                      onLongPress: () => _showBookOptions(context, book),
                      child: _buildBookCard(book),
                    );
                  },
                ),
    );
  }

  Widget _buildBookCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.coverPath.isNotEmpty && File(book.coverPath).existsSync()
                    ? Image.file(
                        File(book.coverPath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultCover(book.title);
                        },
                      )
                    : _buildDefaultCover(book.title),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCover(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.3),
            const Color(0xFF1E1E1E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 48,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookOptions(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              title: const Text(
                'Remove from Collection',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeBookFromCollection(book.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBooksDialog extends StatefulWidget {
  final List<Book> availableBooks;

  const _AddBooksDialog({required this.availableBooks});

  @override
  State<_AddBooksDialog> createState() => _AddBooksDialogState();
}

class _AddBooksDialogState extends State<_AddBooksDialog> {
  final Set<int> _selectedBookIds = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Add Books', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.availableBooks.length,
          itemBuilder: (context, index) {
            final book = widget.availableBooks[index];
            return CheckboxListTile(
              value: _selectedBookIds.contains(book.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedBookIds.add(book.id);
                  } else {
                    _selectedBookIds.remove(book.id);
                  }
                });
              },
              title: Text(
                book.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                book.author,
                style: const TextStyle(color: Colors.white54),
              ),
              activeColor: const Color(0xFF8B5CF6),
              checkColor: Colors.white,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedBookIds.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedBookIds.toList()),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
