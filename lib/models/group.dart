import 'package:files_manager/models/Api_user.dart';

class GroupModel {
  final int id;
  final String name;
  final String description;
  final String color;
  final String lang;
  final int creatorId;
  final List<FileApiModel> files;
  final List<UserModel>? members;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.lang,
    required this.creatorId,
    required this.files,
    this.members,
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
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => UserModel.fromJson(member))
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
      'members': members?.map((member) => member.toJson()).toList(),
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
  final DateTime? dateTime;
  final ActiveCheckin? activeCheckin;

  FileApiModel({
    required this.id,
    required this.name,
    this.path,
    this.extension,
    this.parentId,
    required this.creatorId,
    this.dateTime,
    this.activeCheckin,
  });

  // From JSON
  factory FileApiModel.fromJson(Map<String, dynamic> json) {
    return FileApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      path: json['path'],
      extension: json['extension'],
      parentId: json['parent_id'] != null
          ? int.tryParse(json['parent_id'].toString())
          : null,
      creatorId: json['creator_id'] ?? 0,
      dateTime: json['date_time'] != null
          ? DateTime.tryParse(json['date_time'])
          : null,
      activeCheckin: json['activeCheckin'] != null
          ? ActiveCheckin.fromJson(json['activeCheckin'])
          : null,
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
      'date_time': dateTime?.toIso8601String(),
      'activeCheckin': activeCheckin?.toJson(),
    };
  }
}

class ActiveCheckin {
  final int id;
  final int fileId;
  final int userId;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final UserModel? user;

  ActiveCheckin({
    required this.id,
    required this.fileId,
    required this.userId,
    this.checkedInAt,
    this.checkedOutAt,
    this.user,
  });

  // From JSON
  factory ActiveCheckin.fromJson(Map<String, dynamic> json) {
    return ActiveCheckin(
      id: json['id'] ?? 0,
      fileId: json['file_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.tryParse(json['checked_in_at'])
          : null,
      checkedOutAt: json['checked_out_at'] != null
          ? DateTime.tryParse(json['checked_out_at'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_id': fileId,
      'user_id': userId,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'checked_out_at': checkedOutAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}


