# Language Learning E-Reader

A professional Flutter application for language learning through reading EPUB books with parallel translation support.

## Features

- 📚 **EPUB Reader**: Read EPUB books with a native reading experience
- 🔤 **Parallel Translation**: Tap any word to see instant translations with frequency data
- 🎨 **Beautiful UI**: Deep charcoal theme (#121212) with purple accent (#8B5CF6)
- 💾 **Local Storage**: All data stored locally using Hive
- 📖 **Library Management**: Organize books with "Last Opened" section
- 🌓 **Theme Support**: Light and dark mode support
- ⚡ **State Management**: Riverpod for reactive state management

## Project Structure

```
lib/
├── data/                          # Data Layer
│   ├── local_storage_controller.dart  # Hive storage management
│   ├── translation_service.dart       # Translation logic
│   ├── theme_controller.dart          # Theme management
│   └── providers.dart                 # Riverpod providers
│
├── model/                         # Data Models
│   ├── book.dart                      # Book entity
│   ├── user_settings.dart             # User preferences
│   ├── reading_progress.dart          # Reading state
│   └── translation_data.dart          # Translation cache
│
├── ui/                            # Presentation Layer
│   ├── library_page.dart              # Main library screen
│   ├── reader_page.dart               # Book reader screen
│   └── widgets/
│       ├── book_card.dart             # Book display widget
│       └── translation_popup.dart     # Translation overlay
│
└── main.dart                      # App entry point
```

## Architecture

### Clean Architecture Pattern
- **Data Layer**: Local storage, services, and data sources
- **Domain Layer**: Models and business entities
- **Presentation Layer**: UI screens and widgets

### Key Components

#### LocalStorageController
Manages all Hive operations:
- Book CRUD operations
- User settings persistence
- Reading progress tracking
- Translation caching

#### TranslationService
Handles translation logic:
- Word-to-translation mapping
- Frequency data management
- Segment alignment for parallel text

#### ThemeController
Theme management with:
- Light/Dark mode toggle
- Consistent color scheme
- Dynamic theme switching

## Dependencies

```yaml
# State Management
flutter_riverpod: ^2.4.9

# Local Storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# EPUB Reader
vocsy_epub_viewer: ^3.1.0

# File Picker
file_picker: ^6.1.1

# Code Generation
build_runner: ^2.4.7
hive_generator: ^2.0.1
```

## Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
flutter run
```

## Usage

### Adding Books
1. Tap the "Add Book" button on the library page
2. Select an EPUB file from your device
3. The book will appear in your library

### Reading with Translation
1. Open any book from your library
2. Tap the translation button (floating action button)
3. A demo translation popup will appear showing:
   - The selected word
   - Its translation
   - Frequency data (Very Common, Common, Moderate, Rare)

### Customization
- Adjust font size from the reader settings
- Change translation language
- Toggle between light and dark themes

## Data Models

### Book
```dart
- id: String
- title: String
- author: String
- filePath: String
- coverPath: String?
- addedDate: DateTime
- lastOpenedDate: DateTime?
```

### UserSettings
```dart
- targetLang: String
- fontSize: double
- themeMode: ThemeMode
- sourceLang: String
```

### ReadingProgress
```dart
- bookId: String
- lastLocationCFI: String
- progressPercentage: double
- lastUpdated: DateTime
```

### TranslationData
```dart
- word: String
- translation: String
- frequency: int
- sourceLang: String
- targetLang: String
- lastUsed: DateTime
```

## Design Specifications

### Colors
- Background: `#121212` (Deep Charcoal)
- Text: `#FFFFFF` (Pure White)
- Accent: `#8B5CF6` (Vibrant Purple)
- Surface: `#1E1E1E` (Slightly lighter charcoal)

### Typography
- Default font size: 16.0
- Adjustable range: 12.0 - 24.0

## Future Enhancements

- [ ] Connect to real translation API
- [ ] Add vocabulary tracking
- [ ] Export word lists
- [ ] Reading statistics
- [ ] Cloud sync
- [ ] Multiple language pairs
- [ ] Audio pronunciation
- [ ] Flashcard generation

## License

This project is part of a demonstration and is provided as-is.
