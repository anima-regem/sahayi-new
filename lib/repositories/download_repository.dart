import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../core/errors/app_exception.dart';
import '../core/storage_keys.dart';
import '../models/download_item.dart';
import '../models/resource_item.dart';
import '../services/drive_api_client.dart';

class DownloadRepository {
  DownloadRepository({
    required Dio dio,
    required DriveApiClient driveApiClient,
  })  : _dio = dio,
        _driveApiClient = driveApiClient;

  final Dio _dio;
  final DriveApiClient _driveApiClient;

  Future<List<DownloadItem>> listDownloads() async {
    final box = Hive.box<String>(StorageKeys.downloadsBox);
    final items = <DownloadItem>[];
    for (final value in box.values) {
      if (value.isEmpty) {
        continue;
      }
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      items.add(DownloadItem.fromJson(decoded));
    }
    items.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return items;
  }

  Future<DownloadItem?> getDownloadByResourceId(String resourceId) async {
    final box = Hive.box<String>(StorageKeys.downloadsBox);
    final raw = box.get(resourceId);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final item = DownloadItem.fromJson(decoded);
    if (await File(item.localPath).exists()) {
      return item;
    }
    await box.delete(resourceId);
    return null;
  }

  Future<DownloadItem> ensureDownloaded(ResourceItem item) async {
    final existing = await getDownloadByResourceId(item.id);
    if (existing != null) {
      return existing;
    }
    return download(item);
  }

  Future<DownloadItem> download(ResourceItem item) async {
    final downloadDir = await _ensureDownloadDirectory();
    final destinationPath = path.join(downloadDir.path, '${item.id}.pdf');
    final destinationFile = File(destinationPath);

    try {
      await _dio.download(
        _driveApiClient.buildDownloadUrl(item.id),
        destinationPath,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
    } on DioException catch (error) {
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
      throw _mapDownloadError(error);
    } catch (_) {
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
      throw const AppException(
        type: AppErrorType.unknown,
        message: 'Failed to download the file.',
      );
    }

    final fileSize = await destinationFile.length();
    final downloadItem = DownloadItem(
      resourceId: item.id,
      fileName: item.name,
      localPath: destinationPath,
      department: item.department,
      semester: item.semester,
      subject: item.subject,
      category: item.category,
      downloadedAt: DateTime.now().toUtc(),
      sizeBytes: fileSize,
    );

    final box = Hive.box<String>(StorageKeys.downloadsBox);
    await box.put(item.id, jsonEncode(downloadItem.toJson()));
    return downloadItem;
  }

  Future<void> deleteDownload(String resourceId) async {
    final item = await getDownloadByResourceId(resourceId);
    if (item != null) {
      final file = File(item.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final box = Hive.box<String>(StorageKeys.downloadsBox);
    await box.delete(resourceId);
  }

  Future<Directory> _ensureDownloadDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(path.join(baseDir.path, 'downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  AppException _mapDownloadError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseBody = error.response?.data?.toString() ?? '';
    if (statusCode == 403 || statusCode == 429) {
      if (responseBody.contains('rateLimitExceeded') ||
          responseBody.contains('userRateLimitExceeded') ||
          statusCode == 429) {
        return const AppException(
          type: AppErrorType.quotaExceeded,
          message: 'Google Drive download quota exceeded. Please retry later.',
        );
      }
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppException(
        type: AppErrorType.network,
        message: 'Unable to download file. Please check internet connection.',
      );
    }
    return const AppException(
      type: AppErrorType.unknown,
      message: 'Download failed.',
    );
  }
}
