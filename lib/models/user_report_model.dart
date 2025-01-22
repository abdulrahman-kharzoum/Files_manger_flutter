class UserReportModel {
  final List<UserReportData> data;
  final String message;

  UserReportModel({required this.data, required this.message});

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      data: (json['data'] as List)
          .map((e) => UserReportData.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'message': message,
  };
}

class UserReportData {
  final String message;
  final String date;
  final String type;

  UserReportData({
    required this.message,
    required this.date,
    required this.type,
  });

  factory UserReportData.fromJson(Map<String, dynamic> json) {
    return UserReportData(
      message: json['message'] ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'date': date,
    'type': type,
  };
}