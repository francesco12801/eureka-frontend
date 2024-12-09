class NotificationEureka {
  final String userId;
  final String title;
  final String body;
  final String type;
  bool read;
  final int createdAt;

  NotificationEureka({
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory NotificationEureka.fromJson(Map<String, dynamic> json) {
    return NotificationEureka(
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'NotificationEureka{userId: $userId, title: $title, body: $body, type: $type, read: $read, createdAt: $createdAt}';
  }
}
