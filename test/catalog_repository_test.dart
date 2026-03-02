import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahayi/config/app_config.dart';
import 'package:sahayi/models/catalog_index.dart';
import 'package:sahayi/models/catalog_search_filters.dart';
import 'package:sahayi/models/resource_item.dart';
import 'package:sahayi/repositories/catalog_repository.dart';
import 'package:sahayi/services/catalog_crawler.dart';
import 'package:sahayi/services/drive_api_client.dart';

void main() {
  group('CatalogRepository.search', () {
    late CatalogRepository repository;
    late CatalogIndex index;

    setUp(() {
      const config = AppConfig(
        driveApiKey: 'test-key',
        driveRootFolderId: 'test-root',
      );
      repository = CatalogRepository(
        crawler: CatalogCrawler(
          driveApiClient: DriveApiClient(
            dio: Dio(),
            config: config,
          ),
        ),
        config: config,
      );
      index = CatalogIndex(
        rootFolderId: 'test-root',
        lastSyncedAt: DateTime.utc(2026, 1, 1),
        resources: const [
          ResourceItem(
            id: '1',
            name: 'Math PYQ 2024',
            department: 'CSE',
            semester: 'S1',
            subject: 'Mathematics',
            category: 'PYQ',
            webViewLink: 'https://example.com/1',
          ),
          ResourceItem(
            id: '2',
            name: 'Physics Notes Unit 1',
            department: 'CSE',
            semester: 'S1',
            subject: 'Physics',
            category: 'Notes',
            webViewLink: 'https://example.com/2',
          ),
          ResourceItem(
            id: '3',
            name: 'Mechanics Slides',
            department: 'ME',
            semester: 'S3',
            subject: 'Mechanics',
            category: 'Slides',
            webViewLink: 'https://example.com/3',
          ),
        ],
      );
    });

    test('returns global matches by query across metadata fields', () {
      final results = repository.search(
        index: index,
        query: 'mechanics',
        filters: const CatalogSearchFilters(),
      );

      expect(results.length, 1);
      expect(results.first.id, '3');
    });

    test('applies hierarchy and category filters together', () {
      final results = repository.search(
        index: index,
        query: '',
        filters: const CatalogSearchFilters(
          department: 'CSE',
          semester: 'S1',
          subject: 'Physics',
          categories: {'Notes'},
        ),
      );

      expect(results.length, 1);
      expect(results.first.id, '2');
    });
  });
}
