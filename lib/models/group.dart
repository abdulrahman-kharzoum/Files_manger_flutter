class Group {
  final int id;
  final String name;
  final Creator creator;
  final List<dynamic> joinedUsers;
  final List<dynamic> requests;
  final List<dynamic> groupFiles;
  final String description;
  final String color;
  final String lang;

  Group({
    required this.id,
    required this.name,
    required this.creator,
    required this.joinedUsers,
    required this.requests,
    required this.groupFiles,
    required this.description,
    required this.color,
    required this.lang,
  });

  // From JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      creator: Creator.fromJson(json['creator']),
      joinedUsers: List<dynamic>.from(json['joinedUsers']),
      requests: List<dynamic>.from(json['requests']),
      groupFiles: List<dynamic>.from(json['groupFiles']),
      description: json['description'],
      color: json['color'],
      lang: json['lang'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator': creator.toJson(),
      'joinedUsers': joinedUsers,
      'requests': requests,
      'groupFiles': groupFiles,
      'description': description,
      'color': color,
      'lang': lang,
    };
  }
}

class Creator {
  final int id;
  final String name;
  final String username;
  final String email;
  final bool? admin;
  final List<dynamic> ownedGroups;
  final List<dynamic> joinedGroups;
  final List<dynamic> files;
  final List<dynamic> requests;
  final List<dynamic> checkIns;
  final bool enabled;
  final List<Authority> authorities;
  final bool accountNonExpired;
  final bool credentialsNonExpired;
  final bool accountNonLocked;

  Creator({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.admin,
    required this.ownedGroups,
    required this.joinedGroups,
    required this.files,
    required this.requests,
    required this.checkIns,
    required this.enabled,
    required this.authorities,
    required this.accountNonExpired,
    required this.credentialsNonExpired,
    required this.accountNonLocked,
  });

  // From JSON
  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      admin: json['admin'],
      ownedGroups: List<dynamic>.from(json['ownedGroups']),
      joinedGroups: List<dynamic>.from(json['joinedGroups']),
      files: List<dynamic>.from(json['files']),
      requests: List<dynamic>.from(json['requests']),
      checkIns: List<dynamic>.from(json['checkIns']),
      enabled: json['enabled'],
      authorities: List<Authority>.from(
          json['authorities'].map((x) => Authority.fromJson(x))),
      accountNonExpired: json['accountNonExpired'],
      credentialsNonExpired: json['credentialsNonExpired'],
      accountNonLocked: json['accountNonLocked'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'admin': admin,
      'ownedGroups': ownedGroups,
      'joinedGroups': joinedGroups,
      'files': files,
      'requests': requests,
      'checkIns': checkIns,
      'enabled': enabled,
      'authorities': authorities.map((x) => x.toJson()).toList(),
      'accountNonExpired': accountNonExpired,
      'credentialsNonExpired': credentialsNonExpired,
      'accountNonLocked': accountNonLocked,
    };
  }
}

class Authority {
  final String authority;

  Authority({required this.authority});

  // From JSON
  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      authority: json['authority'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'authority': authority,
    };
  }
}
