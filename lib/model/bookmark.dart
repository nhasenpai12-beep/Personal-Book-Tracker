class Bookmark {
  int id;
  int bookId;
  String note;
  int chapterIndex;
  String? chapterTitle;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.note,
    required this.chapterIndex,
    this.chapterTitle,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'note': note,
        'chapterIndex': chapterIndex,
        'chapterTitle': chapterTitle,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int,
        bookId: json['bookId'] as int,
        note: json['note'] as String,
        chapterIndex: json['chapterIndex'] as int? ?? 0,
        chapterTitle: json['chapterTitle'] as String?,
      );

  Bookmark copyWith({
    int? id,
    int? bookId,
    String? note,
    int? chapterIndex,
    String? chapterTitle,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      note: note ?? this.note,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterTitle: chapterTitle ?? this.chapterTitle,
    );
  }
}
