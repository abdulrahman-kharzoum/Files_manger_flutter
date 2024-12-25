class UserModel {
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

  UserModel({
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
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
      authorities: List<Authority>.from(json['authorities'].map((x) => Authority.fromJson(x))),
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

  factory Authority.fromJson(Map<String, dynamic> json) {
    return Authority(
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authority': authority,
    };
  }
}

class UserResponseRegiester {
  final UserModel model;
  final String token;
  final String message;

  UserResponseRegiester({required this.model, required this.token, required this.message});

  // From JSON
  factory UserResponseRegiester.fromJson(Map<String, dynamic> json) {
    return UserResponseRegiester(
      model: UserModel.fromJson(json['data']['model']),
      token: json['data']['token'],
      message: json['message'],
    );
  }



  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'model': model.toJson(),
        'token': token,
      },
      'message': message,
    };
  }
}

class UserResponseLogin {
  final UserModel model;
  final String token;
  final String message;

  UserResponseLogin({required this.model, required this.token, required this.message});

  // From JSON
  factory UserResponseLogin.fromJson(Map<String, dynamic> json) {
    return UserResponseLogin(
      model: UserModel.fromJson(json['data']['user']),
      token: json['data']['token'],
      message: json['message'],
    );
  }



  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'user': model.toJson(),
        'token': token,
      },
      'message': message,
    };
  }
}
