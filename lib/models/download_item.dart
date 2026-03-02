class DownloadItem {
  const DownloadItem({
    required this.resourceId,
    required this.fileName,
    required this.localPath,
    required this.department,
    required this.semester,
    required this.subject,
    required this.category,
    required this.downloadedAt,
    this.sizeBytes,
  });

  final String resourceId;
  final String fileName;
  final String localPath;
  final String department;
  final String semester;
  final String subject;
  final String category;
  final DateTime downloadedAt;
  final int? sizeBytes;

  String get pathLabel => '$department / $semester / $subject / $category';

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      resourceId: json['resourceId'] as String,
      fileName: json['fileName'] as String,
      localPath: json['localPath'] as String,
      department: json['department'] as String,
      semester: json['semester'] as String,
      subject: json['subject'] as String,
      category: json['category'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      sizeBytes: json['sizeBytes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'fileName': fileName,
      'localPath': localPath,
      'department': department,
      'semester': semester,
      'subject': subject,
      'category': category,
      'downloadedAt': downloadedAt.toIso8601String(),
      'sizeBytes': sizeBytes,
    };
  }
}
