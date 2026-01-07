class Book {
  int id;
  String title;
  String author;
  String coverPath;
  String contentPath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverPath,
    required this.contentPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'coverPath': coverPath,
        'contentPath': contentPath,
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as int,
        title: json['title'] as String,
        author: json['author'] as String,
        coverPath: json['coverPath'] as String,
        contentPath: json['contentPath'] as String,
      );

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? coverPath,
    String? contentPath,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      contentPath: contentPath ?? this.contentPath,
    );
  }
}
