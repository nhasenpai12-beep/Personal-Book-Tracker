class ReadingProgress {
  int bookId;
  int lastPage;

  ReadingProgress({
    required this.bookId,
    required this.lastPage,
  });

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'lastPage': lastPage,
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        bookId: json['bookId'] as int,
        lastPage: json['lastPage'] as int,
      );

  ReadingProgress copyWith({
    int? bookId,
    int? lastPage,
  }) {
    return ReadingProgress(
      bookId: bookId ?? this.bookId,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}
