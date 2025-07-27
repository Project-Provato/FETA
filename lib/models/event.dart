import 'package:flutter/material.dart';

class Event {
  final int? id;
  final String title;
  final String type;
  final String time;
  final String description;
  final int? animalId;

  const Event({
    this.id,
    required this.title,
    required this.type,
    required this.time,
    this.description = '',
    this.animalId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'other',
      time: json['time'] ?? 'All day',
      description: json['description'] ?? '',
      animalId: json['animalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type,
      'time': time,
      'description': description,
      if (animalId != null) 'animalId': animalId,
    };
  }

  Event copyWith({
    int? id,
    String? title,
    String? type,
    String? time,
    String? description,
    int? animalId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      time: time ?? this.time,
      description: description ?? this.description,
      animalId: animalId ?? this.animalId,
    );
  }

  Color getTypeColor() {
    switch (type) {
      case 'medical':
        return Colors.blue;
      case 'emergency':
        return Colors.red;
      case 'feeding':
        return Colors.green;
      case 'checkup':
        return Colors.orange;
      case 'alert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'emergency':
        return Icons.emergency;
      case 'feeding':
        return Icons.restaurant;
      case 'checkup':
        return Icons.health_and_safety;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.event;
    }
  }

  @override
  String toString() => title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.time == time &&
        other.description == description &&
        other.animalId == animalId;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, type, time, description, animalId);
  }
}