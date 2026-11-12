class Book {
  final int? id;
  final String title;
  final String author;
  final String publisher;
  final String year;
  final String category;
  final String description;
  final String coverPath;
  final String location;
  final String status; // خوانده‌شده / در حال خواندن / نخوانده
  final int rating; // 1 to 5
  final String tags;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.publisher = '',
    this.year = '',
    this.category = 'عمومی',
    this.description = '',
    this.coverPath = '',
    this.location = '',
    this.status = 'نخوانده',
    this.rating = 0,
    this.tags = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'year': year,
      'category': category,
      'description': description,
      'coverPath': coverPath,
      'location': location,
      'status': status,
      'rating': rating,
      'tags': tags,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      publisher: map['publisher'] ?? '',
      year: map['year'] ?? '',
      category: map['category'] ?? 'عمومی',
      description: map['description'] ?? '',
      coverPath: map['coverPath'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? 'نخوانده',
      rating: map['rating'] ?? 0,
      tags: map['tags'] ?? '',
    );
  }
}