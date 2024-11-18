class PostData {
  final String avatar;
  final String name;
  final String role;
  final int time;
  String title;
  String content;
  final int likes;
  final int comments;
  final int saved;

  PostData({
    required this.avatar,
    required this.name,
    required this.role,
    this.time = 0,
    required this.title,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    this.saved = 0,
  });
}
