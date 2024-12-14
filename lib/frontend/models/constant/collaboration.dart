enum CollaborationStatus { PENDING, ACCEPTED, DECLINED, CANCELLED }

class Collaboration {
  final String id;
  final String senderId;
  final String receiverId;
  final String genieId;
  final int createdAt;
  final int updatedAt;
  final int expireAt;
  final CollaborationStatus? status;

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
    CollaborationStatus? status;
    if (json['status'] is CollaborationStatus) {
      status = json['status'];
    } else if (json['status'] is String) {
      try {
        status = CollaborationStatus.values.firstWhere(
          (e) => e.toString() == 'CollaborationStatus.${json['status']}',
          orElse: () => CollaborationStatus.PENDING,
        );
      } catch (e) {
        status = CollaborationStatus.PENDING;
      }
    }

    return Collaboration(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      genieId: json['genieId'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      updatedAt: json['updatedAt'] ?? 0,
      expireAt: json['expireAt'] ?? 0,
      status: status,
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
