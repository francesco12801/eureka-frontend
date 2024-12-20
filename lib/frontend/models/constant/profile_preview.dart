import 'package:eureka_final_version/frontend/constants/utils.dart';
import 'package:flutter/cupertino.dart';

class EurekaUserPublic extends SearchResult {
  final String nameSurname;
  final String uid;
  final String profession;
  final String profileImage;

  EurekaUserPublic({
    required this.nameSurname,
    required this.uid,
    required this.profession,
    required this.profileImage,
  });

  static EurekaUserPublic fromMap(Map<String, dynamic> map) {
    return EurekaUserPublic(
      uid: map['uid'] ?? '',
      nameSurname: map['nameSurname'] ?? '',
      profession: map['profession'],
      profileImage: map['profileImage'] ?? placeholderProfilePicture,
    );
  }
}

// Genie result model
class GenieResult implements SearchResult {
  final String title;
  final String id;
  final String description;
  final String category;
  final IconData iconData;

  GenieResult({
    required this.title,
    required this.id,
    required this.description,
    required this.category,
    required this.iconData,
  });
}

// Abstract base class for search results
abstract class SearchResult {}
