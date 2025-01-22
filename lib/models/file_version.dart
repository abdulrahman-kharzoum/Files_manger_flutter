class FileVersion {
  final int id;
  final double version;
  final String path;
  final String comparison;
  final int fileId;
  final int checkInId;
  final String dateTime;

  FileVersion({
    required this.id,
    required this.version,
    required this.path,
    required this.comparison,
    required this.fileId,
    required this.checkInId,
    required this.dateTime,
  });

  factory FileVersion.fromJson(Map<String, dynamic> json) {
    return FileVersion(
      id: json['id'] as int,
      version: (json['version'] as num).toDouble(),
      path: json['path'] as String,
      comparison: json['comparison'] ?? '',
      fileId: json['file_id'] as int,
      checkInId: json['check_in_id'] ?? -1,
      dateTime: json['date_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'path': path,
      'comparison': comparison,
      'file_id': fileId,
      'check_in_id': checkInId,
      'date_time': dateTime,
    };
  }
}
