class NotificationEureka {
  final String id;
  final String fromUserId;
  final String title;
  final String body;
  final String type;
  bool read;
  final int createdAt;

  NotificationEureka({
    required this.id,
    required this.fromUserId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory NotificationEureka.fromJson(Map<String, dynamic> json) {
    return NotificationEureka(
      id: json['id'],
      fromUserId: json['fromUserId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'NotificationEureka{id: $id ,fromUserId: $fromUserId, title: $title, body: $body, type: $type, read: $read, createdAt: $createdAt}';
  }
}
