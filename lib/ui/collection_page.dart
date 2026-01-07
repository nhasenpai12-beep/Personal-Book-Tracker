import 'package:flutter/material.dart';
import 'package:project_proposal/data/storage/local_storage_controller.dart';
import 'package:project_proposal/model/collection.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final _storage = LocalStorageController();
  List<Collection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final collections = await _storage.getAllCollections();
    setState(() {
      _collections = collections;
      _isLoading = false;
    });
  }

  Future<void> _createCollection() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('New Collection', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Collection name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final newId = _collections.isEmpty 
          ? 1 
          : _collections.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      
      final collection = Collection(
        id: newId,
        name: result,
        bookIds: [],
      );
      
      await _storage.saveCollection(collection);
      await _loadCollections();
    }
  }

  Future<void> _deleteCollection(int collectionId) async {
    await _storage.deleteCollection(collectionId);
    await _loadCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: const Text('Collections'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _collections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.collections_bookmark,
                        size: 64,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No collections yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createCollection,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Collection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _collections.length,
                  itemBuilder: (context, index) {
                    final collection = _collections[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.folder,
                          color: Color(0xFF8B5CF6),
                        ),
                        title: Text(
                          collection.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${collection.bookIds.length} books',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCollection(collection.id),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _collections.isNotEmpty
          ? FloatingActionButton(
              onPressed: _createCollection,
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
