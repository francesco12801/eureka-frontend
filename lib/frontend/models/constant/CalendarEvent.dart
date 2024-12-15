import 'dart:ui';

import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final String time;
  final Color color;
  final IconData icon;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
  });
}
