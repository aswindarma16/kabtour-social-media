class Post {
  final String id;
  final String user;
  final String mediaPath;
  DateTime date;
  bool archived;
  String description;

  Post({
    required this.id,
    required this.user,
    required this.description,
    required this.mediaPath,
    required this.date,
    required this.archived
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'description': description,
      'mediaPath': mediaPath,
      'date': date.toIso8601String(),
      'archived': archived,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? "",
      user: json['user'] ?? "Unknown",
      description: json['description'] ?? "-",
      mediaPath: json['mediaPath'] ?? "",
      date: DateTime.parse(json['date'] ?? DateTime.now()),
      archived: json['archived'] ?? false,
    );
  }
}