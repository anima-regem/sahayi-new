import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/download_repository.dart';
import '../services/catalog_crawler.dart';
import '../services/drive_api_client.dart';
import '../state/catalog_controller.dart';
import '../state/catalog_state.dart';
import '../state/downloads_controller.dart';
import '../state/downloads_state.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
});

final driveApiClientProvider = Provider<DriveApiClient>((ref) {
  return DriveApiClient(
    dio: ref.watch(dioProvider),
    config: ref.watch(appConfigProvider),
  );
});

final catalogCrawlerProvider = Provider<CatalogCrawler>((ref) {
  return CatalogCrawler(
    driveApiClient: ref.watch(driveApiClientProvider),
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(
    crawler: ref.watch(catalogCrawlerProvider),
    config: ref.watch(appConfigProvider),
  );
});

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepository(
    dio: ref.watch(dioProvider),
    driveApiClient: ref.watch(driveApiClientProvider),
  );
});

final catalogControllerProvider =
    StateNotifierProvider<CatalogController, CatalogState>((ref) {
  final controller = CatalogController(
    catalogRepository: ref.watch(catalogRepositoryProvider),
  );
  Future<void>.microtask(controller.loadInitial);
  return controller;
});

final downloadsControllerProvider =
    StateNotifierProvider<DownloadsController, DownloadsState>((ref) {
  final controller = DownloadsController(
    downloadRepository: ref.watch(downloadRepositoryProvider),
  );
  Future<void>.microtask(controller.loadDownloads);
  return controller;
});
