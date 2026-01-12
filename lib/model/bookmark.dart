class Bookmark {
  int id;
  int bookId;
  String note;
  int chapterIndex;
  int paragraphIndex;
  String? chapterTitle;
  String? previewText;
  DateTime createdAt;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.note,
    required this.chapterIndex,
    required this.paragraphIndex,
    this.chapterTitle,
    this.previewText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'note': note,
        'chapterIndex': chapterIndex,
        'paragraphIndex': paragraphIndex,
        'chapterTitle': chapterTitle,
        'previewText': previewText,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int,
        bookId: json['bookId'] as int,
        note: json['note'] as String,
        chapterIndex: json['chapterIndex'] as int? ?? 0,
        paragraphIndex: json['paragraphIndex'] as int? ?? 0,
        chapterTitle: json['chapterTitle'] as String?,
        previewText: json['previewText'] as String?,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  Bookmark copyWith({
    int? id,
    int? bookId,
    String? note,
    int? chapterIndex,
    int? paragraphIndex,
    String? chapterTitle,
    String? previewText,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      note: note ?? this.note,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      paragraphIndex: paragraphIndex ?? this.paragraphIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      previewText: previewText ?? this.previewText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
