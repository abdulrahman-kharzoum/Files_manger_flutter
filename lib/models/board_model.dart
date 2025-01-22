import 'dart:io';

import 'package:files_manager/core/functions/color_to_hex.dart';
import 'package:files_manager/models/group.dart';
import 'package:files_manager/models/invited_user_model.dart';
import 'package:files_manager/models/member_model.dart';
import 'package:files_manager/models/user_model.dart';

import '../interfaces/applications_abstract.dart';

class Board {
  int id;
  String uuid;
  int? parentId;
  int userId;
  Language language;
  String? roleInBoard;
  String color;
  String title;
  String description;
  int tasksCommentsCount;
  String icon;
  bool hasImage;
  bool isFavorite;
  String shareLink;
  String image;
  String visibility;
  DateTime createdAt;
  List<Board> children;
  List<Member> members;
  List<InvitedUser> invitedUsers;
  List<Application> allFiles;
  int? boardColorIndex;
  File? imageFile;
  String? CreatorId;
  int? filesNumber;

  int getApplicationSelectedColor() {
    if (boardColorIndex == null) {
      int index = allColors.indexWhere(
        (element) {
          return colorToHex(element['real']!) == color;
        },
      );
      if (index == -1) {
        allColors.last['real'] = hexToColor(color);
        allColors.last['show'] = hexToColor(color);
        return allColors.length - 1;
      }
      return index;
    }
    return boardColorIndex!;
  }

  Board({
    required this.id,
    required this.uuid,
    required this.parentId,
    required this.userId,
    required this.language,
    required this.roleInBoard,
    required this.color,
    required this.allFiles,
    required this.tasksCommentsCount,
    required this.shareLink,
    required this.title,
    required this.description,
    required this.icon,
    required this.hasImage,
    required this.isFavorite,
    required this.image,
    required this.visibility,
    required this.createdAt,
    required this.children,
    required this.members,
    required this.invitedUsers,
     this.CreatorId,
    this.filesNumber
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      uuid: json['uuid'],
      allFiles: [],
      parentId: json['parent_id'],
      shareLink: json['share_link'],
      userId: json['user_id'],
      tasksCommentsCount: json['tasks_comments_count'] ?? 0,
      language: Language.fromJson(json['language']),
      roleInBoard: json['role_in_board'],
      color: json['color'],
      title: json['title'],
      description: json['description'] ?? '',
      icon: json['icon'],
      hasImage: json['has_image'],
      isFavorite: json['is_favorite'] ?? false,
      image: json['image'],
      visibility: json['visibility'],
      createdAt: DateTime.parse(json['created_at']),
      children:
          List<Board>.from(json['children'].map((x) => Board.fromJson(x))),
      members:
          List<Member>.from(json['members'].map((x) => Member.fromJson(x))),
      invitedUsers: List<InvitedUser>.from(
          json['invitations'].map((x) => InvitedUser.fromJson(x))),
    );
  }
  /// Factory constructor to convert `Group` to `Board`
  factory Board.fromGroup(GroupModel group) {
    return Board(
      CreatorId: group.creatorId.toString(),
      id: group.id,
      uuid: 'created', // UUID is not available in Group; leave empty or generate one.
      parentId: null, // Parent ID is not available; leave as null.
      userId: group.creatorId, // Use the creator's ID as userId.
      language: Language(id: 1, name: 'english', code: group.lang, direction: 'lr'), // Map `lang` to `Language`.
      roleInBoard: null, // Role in board is not available; leave as null.
      color: group.color, // Map directly from Group's color.
      allFiles: [],
      tasksCommentsCount: 0, // Not available in Group; default to 0.
      shareLink: '', // Not available in Group; leave empty.
      title: group.name, // Use Group's name as the title.
      description: group.description, // Map directly from Group.
        icon: '\u{263A}', // Icon not available; leave empty.
      hasImage: false, // Not available; default to false.
      isFavorite: false, // Not available; default to false.
      image: '', // Image not available; leave empty.
      visibility: 'public', // Not available; default to 'public'.
      createdAt: DateTime.now(), // Not available; use current time.
      children: [], // Children are not available; leave as empty.
      members: [], // Members need mapping if available in Group.
      invitedUsers: [],
      filesNumber: group.files.length
    );
  }
}
