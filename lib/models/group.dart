class GroupModel {
  final int id;
  final String name;
  final String description;
  final String color;
  final String lang;
  final int creatorId;
  final List<FileApiModel> files;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.lang,
    required this.creatorId,
    required this.files,
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
      files: (json['files'] as List<dynamic>?)
          ?.map((file) => FileApiModel.fromJson(file))
          .toList() ??
          [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'lang': lang,
      'creator_id': creatorId,
      'files': files.map((file) => file.toJson()).toList(),
    };
  }
}

class FileApiModel {
  final int id;
  final String name;
  final String? path;
  final String? extension;
  final int? parentId;
  final int creatorId;

  FileApiModel({
    required this.id,
    required this.name,
    this.path,
    this.extension,
    this.parentId,
    required this.creatorId,
  });

  // From JSON
  factory FileApiModel.fromJson(Map<String, dynamic> json) {
    return FileApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      path: json['path'],
      extension: json['extension'],
      parentId: json['parent_id'],
      creatorId: json['creator_id'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'extension': extension,
      'parent_id': parentId,
      'creator_id': creatorId,
    };
  }
}
