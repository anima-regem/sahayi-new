class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.name,
    required this.department,
    required this.semester,
    required this.subject,
    required this.category,
    required this.webViewLink,
    this.sizeBytes,
    this.modifiedTime,
  });

  final String id;
  final String name;
  final String department;
  final String semester;
  final String subject;
  final String category;
  final String webViewLink;
  final int? sizeBytes;
  final DateTime? modifiedTime;

  String get pathLabel => '$department / $semester / $subject / $category';

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      semester: json['semester'] as String,
      subject: json['subject'] as String,
      category: json['category'] as String,
      webViewLink: json['webViewLink'] as String,
      sizeBytes: json['sizeBytes'] as int?,
      modifiedTime: json['modifiedTime'] == null
          ? null
          : DateTime.parse(json['modifiedTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'semester': semester,
      'subject': subject,
      'category': category,
      'webViewLink': webViewLink,
      'sizeBytes': sizeBytes,
      'modifiedTime': modifiedTime?.toIso8601String(),
    };
  }
}
