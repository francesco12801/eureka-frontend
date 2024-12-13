class Collaboration {
  final String id;
  final String senderId;
  final String receiverId;
  final String genieId;
  final int createdAt;
  final int updatedAt;
  final int expireAt;
  final String? status;

  Collaboration({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.genieId,
    required this.createdAt,
    required this.updatedAt,
    required this.expireAt,
    this.status,
  });

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      genieId: json['genieId'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      expireAt: json['expireAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'genieId': genieId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expireAt': expireAt,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Collaboration{id: $id, senderId: $senderId, receiverId: $receiverId, genieId: $genieId, createdAt: $createdAt, updatedAt: $updatedAt, expireAt: $expireAt, status: $status}';
  }
}
