class GroupModel {
  final int id;
  final String name;
  final String description;
  final String color;
  final String lang;
  final int creatorId;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.lang,
    required this.creatorId,
  });

  // From JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '',
      lang: json['lang'] ?? '',
      creatorId: json['creator_id'] ?? 0,
    );
  }


  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'lang': lang,
        'creator_id': creatorId,
      },
    };
  }
}
