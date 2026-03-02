import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../core/errors/app_exception.dart';

class DriveNode {
  const DriveNode({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.webViewLink,
    this.sizeBytes,
    this.modifiedTime,
  });

  final String id;
  final String name;
  final String mimeType;
  final String webViewLink;
  final int? sizeBytes;
  final DateTime? modifiedTime;

  bool get isFolder => mimeType == DriveApiClient.folderMimeType;

  factory DriveNode.fromJson(Map<String, dynamic> json) {
    return DriveNode(
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String? ?? '',
      webViewLink: json['webViewLink'] as String? ??
          'https://drive.google.com/file/d/${json['id'] as String}/view',
      sizeBytes: int.tryParse((json['size'] ?? '').toString()),
      modifiedTime: json['modifiedTime'] == null
          ? null
          : DateTime.tryParse(json['modifiedTime'] as String),
    );
  }
}

class DriveApiClient {
  DriveApiClient({
    required Dio dio,
    required AppConfig config,
  })  : _dio = dio,
        _config = config;

  static const folderMimeType = 'application/vnd.google-apps.folder';
  static const pdfMimeType = 'application/pdf';
  static const _baseUrl = 'https://www.googleapis.com/drive/v3';

  final Dio _dio;
  final AppConfig _config;

  Future<List<DriveNode>> listChildren(String parentId) async {
    final nodes = <DriveNode>[];
    String? pageToken;
    do {
      final payload = await _listChildrenPage(parentId, pageToken: pageToken);
      final files = payload['files'] as List<dynamic>? ?? const [];
      nodes.addAll(files
          .map((item) => DriveNode.fromJson(item as Map<String, dynamic>)));
      pageToken = payload['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);
    return nodes;
  }

  String buildDownloadUrl(String fileId) {
    return '$_baseUrl/files/$fileId?alt=media&key=${_config.driveApiKey}';
  }

  Future<Map<String, dynamic>> _listChildrenPage(
    String parentId, {
    String? pageToken,
  }) async {
    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '$_baseUrl/files',
          queryParameters: <String, dynamic>{
            'key': _config.driveApiKey,
            'q': "'$parentId' in parents and trashed=false",
            'fields':
                'nextPageToken,files(id,name,mimeType,size,modifiedTime,webViewLink)',
            'orderBy': 'folder,name',
            'includeItemsFromAllDrives': true,
            'supportsAllDrives': true,
            'pageSize': 1000,
            if (pageToken != null && pageToken.isNotEmpty)
              'pageToken': pageToken,
          },
        );
        return response.data ?? <String, dynamic>{};
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode ?? 0;
        final isRetryableNetwork =
            error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout;
        final isRetryableStatus = statusCode == 429 ||
            statusCode == 500 ||
            statusCode == 502 ||
            statusCode == 503 ||
            statusCode == 504;
        if (attempt < maxAttempts &&
            (isRetryableNetwork || isRetryableStatus)) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
        throw _mapDioError(error);
      } catch (_) {
        throw const AppException(
          type: AppErrorType.unknown,
          message: 'Failed to fetch data from Google Drive.',
        );
      }
    }
  }

  AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final responseData = error.response?.data;
    final responseText = responseData == null ? '' : responseData.toString();

    if (statusCode == 403 || statusCode == 429) {
      if (responseText.contains('rateLimitExceeded') ||
          responseText.contains('userRateLimitExceeded') ||
          statusCode == 429) {
        return const AppException(
          type: AppErrorType.quotaExceeded,
          message:
              'Google Drive API quota has been exceeded. Try again after some time.',
        );
      }
      return const AppException(
        type: AppErrorType.network,
        message: 'Google Drive rejected the request (403).',
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppException(
        type: AppErrorType.network,
        message: 'No internet connection or request timed out.',
      );
    }

    return AppException(
      type: AppErrorType.unknown,
      message: 'Drive request failed (status: $statusCode).',
    );
  }
}
