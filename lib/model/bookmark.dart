class Bookmark {
  int id;
  int bookId;
  String note;
  int chapterIndex;
  String? chapterTitle;
  String? previewText;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.note,
    required this.chapterIndex,
    this.chapterTitle,
    this.previewText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'note': note,
        'chapterIndex': chapterIndex,
        'chapterTitle': chapterTitle,
        'previewText': previewText,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int,
        bookId: json['bookId'] as int,
        note: json['note'] as String,
        chapterIndex: json['chapterIndex'] as int? ?? 0,
        chapterTitle: json['chapterTitle'] as String?,
        previewText: json['previewText'] as String?,
      );

  Bookmark copyWith({
    int? id,
    int? bookId,
    String? note,
    int? chapterIndex,
    String? chapterTitle,
    String? previewText,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      note: note ?? this.note,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      previewText: previewText ?? this.previewText,
    );
  }
}
