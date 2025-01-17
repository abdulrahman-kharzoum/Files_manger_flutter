import 'package:files_manager/models/Api_user.dart';
import 'package:files_manager/models/group.dart';

class Invite {
  final int id;
  final String invitationExpiresAt;
  final String? joinedAt;
  final int inviterId;
  final int groupId;
  final int userId;
  final UserModel user;
  final UserModel inviter;
  final GroupModel group;

  Invite({
    required this.id,
    required this.invitationExpiresAt,
    this.joinedAt,
    required this.inviterId,
    required this.groupId,
    required this.userId,
    required this.user,
    required this.inviter,
    required this.group,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'],
      invitationExpiresAt: json['invitation_expires_at'],
      joinedAt: json['joined_at'],
      inviterId: json['inviter_id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      user: UserModel.fromJson(json['user']),
      inviter: UserModel.fromJson(json['inviter']),
      group: GroupModel.fromJson(json['group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitation_expires_at': invitationExpiresAt,
      'joined_at': joinedAt,
      'inviter_id': inviterId,
      'group_id': groupId,
      'user_id': userId,
      'user': user.toJson(),
      'inviter': inviter.toJson(),
      'group': group.toJson(),
    };
  }
}

class InvitationResponse {
  final List<Invite> invitationsFromMe;
  final List<Invite> invitationsToMe;
  final String message;

  InvitationResponse({
    required this.invitationsFromMe,
    required this.invitationsToMe,
    required this.message,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      invitationsFromMe: (json['invitationsFromMe'] as List?)
          ?.map((i) => Invite.fromJson(i))
          .toList() ??
          [], // Handle null by defaulting to an empty list
      invitationsToMe: (json['invitationsToMe'] as List?)
          ?.map((i) => Invite.fromJson(i))
          .toList() ??
          [], // Handle null by defaulting to an empty list
      message: json['message'] ?? '', // Handle null by defaulting to an empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitationsFromMe': invitationsFromMe.map((i) => i.toJson()).toList(),
      'invitationsToMe': invitationsToMe.map((i) => i.toJson()).toList(),
      'message': message,
    };
  }
}
