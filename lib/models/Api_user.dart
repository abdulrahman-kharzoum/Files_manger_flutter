class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0, // Default to 0 if null
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if null
      email: json['email'] ?? '', // Default to empty if null
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
class TokenModel {
  final String token;
  final String type;

  TokenModel({
    required this.token,
    this.type = '', // Default empty if type is unavailable
  });

  // From JSON
  factory TokenModel.fromJson(dynamic json) {
    if (json is String) {
      // Token is returned as a string
      return TokenModel(token: json);
    } else if (json is Map<String, dynamic>) {
      // Token is returned as a map
      return TokenModel(
        token: json['token'] ?? '',
        type: json['type'] ?? '',
      );
    }
    // Fallback for unexpected cases
    return TokenModel(token: '');
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (type.isNotEmpty) 'type': type, // Include type only if it's not empty
    };
  }
}

class UserResponse {
  final UserModel user;
  final TokenModel token;
  final String message;

  UserResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  // From JSON
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      user: UserModel.fromJson(json['data']['user']),
      token: TokenModel.fromJson(json['data']['token']),
      message: json['message'] ?? 'Success',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'user': user.toJson(),
        'token': token.toJson(),
      },
      'message': message,
    };
  }
}


