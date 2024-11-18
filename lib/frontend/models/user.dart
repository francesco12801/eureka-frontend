import 'dart:convert';
import 'package:flutter/material.dart';

@immutable
class EurekaUser {
  const EurekaUser({
    required this.nameSurname,
    required this.interests,
    required this.university,
    required this.purpose,
    required this.profession,
    this.profileImage,
    this.bannerImage,
    this.description,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.createdAt,
    this.lastLogin,
  });

  factory EurekaUser.fromMap(Map<String, dynamic> map) {
    return EurekaUser(
      nameSurname: map['nameSurname'] as String? ?? '',
      interests: map['interests'] != null
          ? (map['interests'] is String
              ? (map['interests'] as String).split(', ')
              : List<String>.from(map['interests'] as List))
          : [],
      purpose: map['purpose'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      university: map['university'] as String? ?? '',
      profileImage: map['profileImage'] as String?,
      bannerImage: map['bannerImage'] as String?,
      description: map['description'] as String?,
      bio: map['bio'] as String?,
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
      postsCount: map['postsCount'] as int? ?? 0,
      createdAt: map['createdAt'] as String?,
      lastLogin: map['lastLogin'] as String?,
    );
  }

  final String nameSurname;
  final List<String> interests;
  final String university;
  final String purpose;
  final String profession;
  final String? profileImage;
  final String? bannerImage;
  final String? description;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String? createdAt; // Timestamp when user was created
  final String? lastLogin; // Timestamp of last login

  Map<String, dynamic> toMap() {
    return {
      'nameSurname': nameSurname,
      'interests': interests.join(', '),
      'purpose': purpose,
      'university': university,
      'profession': profession,
      'profileImage': profileImage,
      'bannerImage': bannerImage,
      'description': description,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  EurekaUser copyWith({
    String? profileImage,
    String? bannerImage,
  }) {
    return EurekaUser(
      nameSurname: nameSurname,
      interests: interests,
      university: university,
      purpose: purpose,
      profession: profession,
      profileImage: profileImage ?? this.profileImage,
      bannerImage: bannerImage ?? this.bannerImage,
      description: description,
      bio: bio,
      followersCount: followersCount,
      followingCount: followingCount,
      postsCount: postsCount,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  EurekaUser clearUser() {
    return const EurekaUser(
      nameSurname: '',
      interests: [],
      university: '',
      purpose: '',
      profession: '',
      profileImage: null,
      bannerImage: null,
      description: null,
      bio: null,
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      createdAt: null,
      lastLogin: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EurekaUser.fromJson(String source) =>
      EurekaUser.fromMap(json.decode(source) as Map<String, dynamic>);
}
