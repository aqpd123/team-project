class CelebrityModel {
  CelebrityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.gender,
    required this.thumbnail,
    required this.characterType,
    required this.element,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final int gender;
  final String thumbnail;
  final String characterType;
  final String element;

  factory CelebrityModel.fromJson(Map<String, dynamic> json) {
    return CelebrityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      gender: json['gender'] as int,
      thumbnail: json['thumbnail'] as String? ?? '',
      characterType: json['character_type'] as String? ?? '',
      element: json['element'] as String? ?? '목',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'gender': gender,
      'thumbnail': thumbnail,
      'character_type': characterType,
      'element': element,
    };
  }
}

