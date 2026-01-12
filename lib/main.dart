import 'package:flutter/material.dart';
import 'package:project_proposal/data/storage/local_storage_controller.dart';
import 'package:project_proposal/ui/library_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize JSON storage
  final localStorage = LocalStorageController();
  await localStorage.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  
  // Global key to access state from anywhere
  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  final _storage = LocalStorageController();
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final settings = await _storage.getUserSettings();
    if (mounted) {
      setState(() {
        _darkMode = settings?.darkMode ?? true;
      });
    }
  }

  // Method to toggle theme from anywhere in the app
  Future<void> toggleTheme() async {
    setState(() {
      _darkMode = !_darkMode;
    });
    // Save to storage
    final settings = await _storage.getUserSettings();
    if (settings != null) {
      settings.darkMode = _darkMode;
      await _storage.saveUserSettings(settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Learning E-Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LibraryPage(),
    );
  }
}
