class Collection {
  int id;
  String name;
  List<int> bookIds;

  Collection({
    required this.id,
    required this.name,
    required this.bookIds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bookIds': bookIds,
      };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as int,
        name: json['name'] as String,
        bookIds: List<int>.from(json['bookIds'] as List),
      );

  Collection copyWith({
    int? id,
    String? name,
    List<int>? bookIds,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      bookIds: bookIds ?? this.bookIds,
    );
  }
}
