import 'package:flutter/material.dart';
import 'package:project_proposal/data/storage/local_storage_controller.dart';
import 'package:project_proposal/data/storage/file_import_controller.dart';
import 'package:project_proposal/model/book.dart';
import 'package:project_proposal/model/user_settings.dart';
import 'package:project_proposal/ui/reader_page.dart';
import 'package:project_proposal/ui/collection_page.dart';
import 'dart:io';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _storage = LocalStorageController();
  final _fileImporter = FileImportController();
  final _searchController = TextEditingController();
  
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  UserSettings _settings = UserSettings();
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'title'; // 'title', 'author', 'recent'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final books = await _storage.getAllBooks();
    final settings = await _storage.getUserSettings();
    setState(() {
      _books = books;
      _filteredBooks = books;
      _settings = settings ?? UserSettings();
      _isLoading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      // Apply search filter
      _filteredBooks = _books.where((book) {
        if (_searchQuery.isEmpty) return true;
        return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      // Apply sort
      switch (_sortBy) {
        case 'title':
          _filteredBooks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case 'author':
          _filteredBooks.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
          break;
        case 'recent':
          _filteredBooks = _filteredBooks.reversed.toList(); // Most recently added first
          break;
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _onSortChanged(String? sortBy) {
    if (sortBy != null) {
      _sortBy = sortBy;
      _applyFilters();
    }
  }

  Future<void> onImportFile() async {
    final path = await _fileImporter.pickFile();
    if (path != null) {
      final localPath = await _fileImporter.copyToLocalStorage(path);
      if (localPath != null && mounted) {
        // Extract metadata from EPUB
        final metadata = await _fileImporter.extractMetadata(localPath);
        
        final newId = _books.isEmpty ? 1 : _books.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
        
        final book = Book(
          id: newId,
          title: metadata['title'],
          author: metadata['author'],
          coverPath: metadata['coverPath'],
          contentPath: localPath,
        );
        
        await _storage.saveToLocalJSON(book);
        await _loadData();
      }
    }
  }

  Future<void> onToggleTheme() async {
    _settings.darkMode = !_settings.darkMode;
    await _storage.saveUserSettings(_settings);
    setState(() {});
  }

  Future<void> onDeleteBook(int bookId) async {
    await _storage.deleteBook(bookId);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text(
          'My Library',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _settings.darkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: onToggleTheme,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1E1E1E),
            onSelected: _onSortChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'title' ? Icons.check : Icons.sort_by_alpha,
                      color: _sortBy == 'title' ? const Color(0xFF8B5CF6) : Colors.white70,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sort by Title',
                      style: TextStyle(
                        color: _sortBy == 'title' ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'author',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'author' ? Icons.check : Icons.person,
                      color: _sortBy == 'author' ? const Color(0xFF8B5CF6) : Colors.white70,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sort by Author',
                      style: TextStyle(
                        color: _sortBy == 'author' ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'recent' ? Icons.check : Icons.access_time,
                      color: _sortBy == 'recent' ? const Color(0xFF8B5CF6) : Colors.white70,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recently Added',
                      style: TextStyle(
                        color: _sortBy == 'recent' ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CollectionPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search books by title or author...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Books Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                : _filteredBooks.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
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
                            child: Container(
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onImportFile,
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add),
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

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.white38),
            const SizedBox(height: 20),
            const Text(
              'No books found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books, size: 80, color: Colors.white38),
          const SizedBox(height: 20),
          const Text(
            'Your library is empty',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap + to add a book',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Book', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onDeleteBook(book.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
