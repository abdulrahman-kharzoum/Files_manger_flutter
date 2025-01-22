class FileReportModel {
  final List<FileOperation> data;
  final String message;

  FileReportModel({
    required this.data,
    required this.message,
  });

  // Factory method to create a FileReportModel from JSON
  factory FileReportModel.fromJson(Map<String, dynamic> json) {
    return FileReportModel(
      data: (json['data'] as List)
          .map((item) => FileOperation.fromJson(item))
          .toList(),
      message: json['message'],
    );
  }

  // Method to convert FileReportModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((operation) => operation.toJson()).toList(),
      'message': message,
    };
  }
}

class FileOperation {
  final String message;
  final String date;
  final String operation;
  final String user;

  FileOperation({
    required this.message,
    required this.date,
    required this.operation,
    required this.user,
  });

  // Factory method to create a FileOperation from JSON
  factory FileOperation.fromJson(Map<String, dynamic> json) {
    return FileOperation(
      message: json['message'],
      date: json['date'],
      operation: json['operation'],
      user: json['user'],
    );
  }

  // Method to convert FileOperation to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'date': date,
      'operation': operation,
      'user': user,
    };
  }
}