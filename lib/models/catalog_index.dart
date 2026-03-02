import 'resource_item.dart';

class CatalogIndex {
  const CatalogIndex({
    required this.rootFolderId,
    required this.resources,
    required this.lastSyncedAt,
  });

  final String rootFolderId;
  final List<ResourceItem> resources;
  final DateTime lastSyncedAt;

  factory CatalogIndex.fromJson(Map<String, dynamic> json) {
    final resourcesJson = (json['resources'] as List<dynamic>? ?? const []);
    return CatalogIndex(
      rootFolderId: json['rootFolderId'] as String,
      resources: resourcesJson
          .map((item) => ResourceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rootFolderId': rootFolderId,
      'resources': resources.map((item) => item.toJson()).toList(),
      'lastSyncedAt': lastSyncedAt.toIso8601String(),
    };
  }
}
