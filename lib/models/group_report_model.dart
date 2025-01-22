// group_report_model.dart
class GroupReportModel {
  final List<GroupReportData> data;
  final String message;

  GroupReportModel({required this.data, required this.message});

  factory GroupReportModel.fromJson(Map<String, dynamic> json) {
    return GroupReportModel(
      data: (json['data'] as List)
          .map((e) => GroupReportData.fromJson(e))
          .toList(),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'message': message,
  };
}

class GroupReportData {
  final String message;
  final String date;
  final String? operation;
  final String? user;

  GroupReportData({
    required this.message,
    required this.date,
    this.operation,
    this.user,
  });

  factory GroupReportData.fromJson(Map<String, dynamic> json) {
    return GroupReportData(
      message: json['message'],
      date: json['date'],
      operation: json['operation'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'date': date,
    'operation': operation,
    'user': user,
  };
}