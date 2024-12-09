import 'package:flutter/src/widgets/icon_data.dart';

class Genie {
  // Constants
  final String? id;
  final String? userId;
  final String title;
  final String description;
  final String? location;
  final int? createdAt;
  final String nameSurnameCreator;
  final String target;

  // Nullable fields
  final List<String>? videos;
  final List<String>? images;
  final List<String>? files;
  final List<String>? collaborators;
  final List<String>? tags;
  final String? professionUser;
  final String? profileImageUser;
  final int likes;
  final int comments;
  final int saved;

  // Constructor
  Genie({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    this.location,
    this.createdAt,
    required this.nameSurnameCreator,
    required this.target,
    this.videos,
    this.images,
    this.files,
    this.collaborators,
    this.tags,
    this.professionUser,
    this.profileImageUser,
    this.likes = 0,
    this.comments = 0,
    this.saved = 0,
  });

  // Factory constructor to create a Genie instance from a map
  factory Genie.fromMap(Map<String, dynamic> data) {
    return Genie(
      id: data['id'] as String? ?? '', // Provide a default value if null
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      createdAt: data['createdAt'] as int? ?? 0,
      nameSurnameCreator: data['nameSurnameCreator'] as String? ?? '',
      target: data['target'] as String? ?? '',
      videos: (data['videos'] as List<dynamic>?)?.cast<String>(),
      images: (data['images'] as List<dynamic>?)?.cast<String>(),
      files: (data['files'] as List<dynamic>?)?.cast<String>(),
      collaborators: (data['collaborators'] as List<dynamic>?)?.cast<String>(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>(),
      professionUser: data['professionUser'] as String?, // Nullable field
      profileImageUser: data['profileImageUser'] as String?, // Nullable field
      likes: data['likes'] as int? ?? 0,
      comments: data['comments'] as int? ?? 0,
      saved: data['saved'] as int? ?? 0,
    );
  }

  IconData? get iconData => null;

  // Method to convert a Genie instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'createdAt': createdAt,
      'nameSurnameCreator': nameSurnameCreator,
      'target': target,
      'videos': videos,
      'images': images,
      'files': files,
      'collaborators': collaborators,
      'tags': tags,
      'professionUser': professionUser,
      'profileImageUser': profileImageUser,
      'likes': likes,
      'comments': comments,
      'saved': saved,
    };
  }

  // FromJson method
  factory Genie.fromJson(Map<String, dynamic> json) {
    return Genie(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      createdAt: json['createdAt'] as int?,
      nameSurnameCreator: json['nameSurnameCreator'] as String,
      target: json['target'] as String,
      videos: (json['videos'] as List<dynamic>?)?.cast<String>(),
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      files: (json['files'] as List<dynamic>?)?.cast<String>(),
      collaborators: (json['collaborators'] as List<dynamic>?)?.cast<String>(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      professionUser: json['professionUser'] as String?,
      profileImageUser: json['profileImageUser'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      saved: json['saved'] as int? ?? 0,
    );
  }

  // CopyWith method
  Genie copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    int? createdAt,
    String? nameSurnameCreator,
    String? target,
    List<String>? videos,
    List<String>? images,
    List<String>? files,
    List<String>? collaborators,
    List<String>? tags,
    String? professionUser,
    String? profileImageUser,
    int? likes,
    int? comments,
    int? saved,
  }) {
    return Genie(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      nameSurnameCreator: nameSurnameCreator ?? this.nameSurnameCreator,
      target: target ?? this.target,
      videos: videos ?? this.videos,
      images: images ?? this.images,
      files: files ?? this.files,
      collaborators: collaborators ?? this.collaborators,
      tags: tags ?? this.tags,
      professionUser: professionUser ?? this.professionUser,
      profileImageUser: profileImageUser ?? this.profileImageUser,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      saved: saved ?? this.saved,
    );
  }
}
