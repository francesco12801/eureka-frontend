import 'package:flutter/material.dart';

class Meeting {
  final String id;
  final DateTime createdAt;
  final String title;
  final DateTime day;
  final TimeOfDay time;
  final String? addInfo;
  final String creatorId;
  final String guestId;
  final String? genieId;
  final List<String>? participants;

  Meeting({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.day,
    required this.time,
    this.addInfo,
    required this.creatorId,
    required this.guestId,
    this.participants,
    this.genieId,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      title: json['title'],
      day: DateTime.parse(json['day']),
      time: TimeOfDay(
        hour: int.parse(json['time'].split(":")[0]),
        minute: int.parse(json['time'].split(":")[1]),
      ),
      addInfo: json['addInfo'],
      genieId: json['genieId'],
      creatorId: json['creatorId'],
      guestId: json['guestId'],
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'genieId': genieId,
      'day': day.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'addInfo': addInfo,
      'creatorId': creatorId,
      'guestId': guestId,
      'participants': participants,
    };
  }
}
