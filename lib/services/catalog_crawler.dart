import '../core/errors/app_exception.dart';
import '../models/catalog_index.dart';
import '../models/resource_item.dart';
import 'drive_api_client.dart';

class CatalogCrawler {
  CatalogCrawler({
    required DriveApiClient driveApiClient,
  }) : _driveApiClient = driveApiClient;

  final DriveApiClient _driveApiClient;

  Future<CatalogIndex> crawl(String rootFolderId) async {
    final resources = <ResourceItem>[];
    final departmentFolders = await _listFolders(rootFolderId);

    if (departmentFolders.isEmpty) {
      throw const AppException(
        type: AppErrorType.malformedStructure,
        message:
            'No department folders found in the configured root Google Drive folder.',
      );
    }

    for (final department in departmentFolders) {
      final semesterFolders = await _listFolders(department.id);
      for (final semester in semesterFolders) {
        final subjectFolders = await _listFolders(semester.id);
        for (final subject in subjectFolders) {
          final categoryFolders = await _listFolders(subject.id);
          for (final category in categoryFolders) {
            final children = await _driveApiClient.listChildren(category.id);
            final pdfFiles = children
                .where((node) => node.mimeType == DriveApiClient.pdfMimeType)
                .toList();

            for (final pdf in pdfFiles) {
              resources.add(
                ResourceItem(
                  id: pdf.id,
                  name: pdf.name,
                  department: department.name,
                  semester: semester.name,
                  subject: subject.name,
                  category: category.name,
                  webViewLink: pdf.webViewLink,
                  sizeBytes: pdf.sizeBytes,
                  modifiedTime: pdf.modifiedTime,
                ),
              );
            }
          }
        }
      }
    }

    return CatalogIndex(
      rootFolderId: rootFolderId,
      resources: resources,
      lastSyncedAt: DateTime.now().toUtc(),
    );
  }

  Future<List<DriveNode>> _listFolders(String parentId) async {
    final children = await _driveApiClient.listChildren(parentId);
    final folders = children.where((node) => node.isFolder).toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return folders;
  }
}
