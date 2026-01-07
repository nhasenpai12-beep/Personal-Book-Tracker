# Test Data

This folder contains **example JSON files** showing the data structure used by the app.

## Location of Actual JSON Files

When the app runs, it creates JSON files in the system's app data directory:

- **Linux**: `~/.local/share/project_proposal/data/`
- **Android**: `/data/data/com.example.project_proposal/app_flutter/data/`
- **iOS**: `~/Library/Application Support/project_proposal/data/`

## Files Created at Runtime

- `books.json` - All books in the library
- `user_settings.json` - User preferences (font size, dark mode)
- `reading_progress.json` - Reading progress for all books
- `collections.json` - User-created book collections
- `bookmarks_[bookId].json` - Bookmarks for each book
- `reading_progress_[bookId].json` - Individual book progress

## View Runtime Data on Linux

```bash
# View books
cat ~/.local/share/project_proposal/data/books.json | jq

# View settings
cat ~/.local/share/project_proposal/data/user_settings.json | jq

# List all JSON files
ls -lh ~/.local/share/project_proposal/data/
```

## Note

These test files are for **reference only**. The app generates its own JSON files at runtime in the app data directory.
