// lib/models/post.dart
class Post {
  final int id;
  final String title;
  final String body;
  int votes;
  bool saved;

  Post({
    required this.id, 
    required this.title, 
    required this.body,
    this.votes = 0,
    this.saved = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}