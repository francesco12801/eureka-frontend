class Genie {
  final String? id;
  final String title;
  final int likes;
  final int comments;
  final int saved;
  final String description;
  final String target;
  final String? location;
  final String? images;
  final String? videos;
  final String? files;
  final String nameSurnameUser;
  final String professionUser;
  final List<String>? collaborators;
  final List<String>? tags;
  final String? createdAt;
  final String? license;
  // uid of user who created the genie
  // image picture of the user
  // nameSurname name and surname of the user
  // the above fiels must be taken from the backend not fetched here --> I have to change.

  Genie(
      {this.id,
      required this.title,
      required this.description,
      required this.target,
      this.likes = 0,
      this.comments = 0,
      this.saved = 0,
      this.location,
      this.images,
      this.videos,
      this.files,
      required this.license,
      required this.nameSurnameUser,
      required this.professionUser,
      this.collaborators,
      this.tags,
      this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'target': target,
      'location': location,
      'images': images,
      'likes': likes,
      'comments': comments,
      'saved': saved,
      'videos': videos,
      'files': files,
      'license': license,
      'nameSurnameUser': nameSurnameUser,
      'professionUser': professionUser,
      'collaborators': collaborators,
      'tags': tags,
      'createdAt': createdAt,
    };
  }

  factory Genie.fromMap(Map<String, dynamic> map) {
    return Genie(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      target: map['target'] as String,
      location: map['location'] as String?,
      likes: map['likes'] as int,
      comments: map['comments'] as int,
      saved: map['saved'] as int,
      images: map['images'] as String?,
      videos: map['videos'] as String?,
      files: map['files'] as String?,
      license: map['license'] as String,
      nameSurnameUser: map['nameSurnameUser'] as String,
      professionUser: map['professionUser'] as String,
      collaborators: map['collaborators'] != null
          ? (map['collaborators'] is String
              ? (map['collaborators'] as String).split(', ')
              : List<String>.from(map['collaborators'] as List))
          : [],
      tags: map['tags'] != null
          ? (map['tags'] is String
              ? (map['tags'] as String).split(', ')
              : List<String>.from(map['tags'] as List))
          : [],
      createdAt: map['createdAt'] as String?,
    );
  }

  Genie copyWith({
    String? id,
    String? userID,
    String? title,
    String? description,
    String? target,
    String? location,
    String? images,
    int? likes,
    int? comments,
    int? saved,
    String? videos,
    String? files,
    String? license,
    String? nameSurnameUser,
    String? professionUser,
    List<String>? collaborators,
    List<String>? tags,
    String? createdAt,
  }) {
    return Genie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      target: target ?? this.target,
      location: location ?? this.location,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      saved: saved ?? this.saved,
      videos: videos ?? this.videos,
      files: files ?? this.files,
      license: license ?? this.license,
      nameSurnameUser: nameSurnameUser ?? this.nameSurnameUser,
      professionUser: professionUser ?? this.professionUser,
      collaborators: collaborators ?? this.collaborators,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
