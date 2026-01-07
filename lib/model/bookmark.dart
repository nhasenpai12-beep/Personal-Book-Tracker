class Bookmark {
  int id;
  int bookId;
  String note;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'note': note,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int,
        bookId: json['bookId'] as int,
        note: json['note'] as String,
      );

  Bookmark copyWith({
    int? id,
    int? bookId,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      note: note ?? this.note,
    );
  }
}
