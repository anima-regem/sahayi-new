import 'dart:convert';

import 'package:hive/hive.dart';

import '../config/app_config.dart';
import '../core/storage_keys.dart';
import '../models/catalog_index.dart';
import '../models/catalog_search_filters.dart';
import '../models/resource_item.dart';
import '../services/catalog_crawler.dart';

class CatalogRepository {
  CatalogRepository({
    required CatalogCrawler crawler,
    required AppConfig config,
  })  : _crawler = crawler,
        _config = config;

  final CatalogCrawler _crawler;
  final AppConfig _config;

  Future<CatalogIndex?> getCachedCatalog() async {
    final box = Hive.box<String>(StorageKeys.catalogBox);
    final raw = box.get(StorageKeys.catalogIndex);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return CatalogIndex.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<CatalogIndex> getCatalog({required bool forceRefresh}) async {
    if (!forceRefresh) {
      final cached = await getCachedCatalog();
      if (cached != null) {
        return cached;
      }
    }
    return refreshCatalog();
  }

  Future<CatalogIndex> refreshCatalog() async {
    final index = await _crawler.crawl(_config.driveRootFolderId);
    final box = Hive.box<String>(StorageKeys.catalogBox);
    await box.put(StorageKeys.catalogIndex, jsonEncode(index.toJson()));
    return index;
  }

  List<ResourceItem> search({
    required CatalogIndex index,
    required String query,
    required CatalogSearchFilters filters,
  }) {
    Iterable<ResourceItem> results = index.resources;
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isNotEmpty) {
      results = results.where((item) {
        return item.name.toLowerCase().contains(normalizedQuery) ||
            item.department.toLowerCase().contains(normalizedQuery) ||
            item.semester.toLowerCase().contains(normalizedQuery) ||
            item.subject.toLowerCase().contains(normalizedQuery) ||
            item.category.toLowerCase().contains(normalizedQuery);
      });
    }

    if (filters.department != null && filters.department!.isNotEmpty) {
      results = results.where((item) => item.department == filters.department);
    }

    if (filters.semester != null && filters.semester!.isNotEmpty) {
      results = results.where((item) => item.semester == filters.semester);
    }

    if (filters.subject != null && filters.subject!.isNotEmpty) {
      results = results.where((item) => item.subject == filters.subject);
    }

    if (filters.categories.isNotEmpty) {
      results =
          results.where((item) => filters.categories.contains(item.category));
    }

    final ordered = results.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ordered;
  }
}
