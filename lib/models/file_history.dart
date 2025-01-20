class FileHistory {
  final int id;
  final double version;
  final String path;
  final String? comparison;
  final int fileId;
  final int? checkInId;
  final DateTime dateTime;

  FileHistory({
    required this.id,
    required this.version,
    required this.path,
    this.comparison,
    required this.fileId,
    this.checkInId,
    required this.dateTime,
  });

  // Factory method to create an instance from JSON
  factory FileHistory.fromJson(Map<String, dynamic> json) {
    return FileHistory(
      id: json['id'],
      version: json['version'] is int
          ? (json['version'] as int).toDouble()
          : json['version'],
      path: json['path'],
      comparison: json['comparison'],
      fileId: json['file_id'],
      checkInId: json['check_in_id'],
      dateTime: DateTime.parse(json['date_time']),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'path': path,
      'comparison': comparison,
      'file_id': fileId,
      'check_in_id': checkInId,
      'date_time': dateTime.toIso8601String(),
    };
  }
}

class FileHistoryResponse {
  final List<FileHistory> data;
  final String message;

  FileHistoryResponse({required this.data, required this.message});

  // Factory method to create an instance from JSON
  factory FileHistoryResponse.fromJson(Map<String, dynamic> json) {
    return FileHistoryResponse(
      data: (json['data'] as List)
          .map((item) => FileHistory.fromJson(item))
          .toList(),
      message: json['message'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }
}
