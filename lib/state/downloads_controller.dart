import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/download_item.dart';
import '../models/resource_item.dart';
import '../repositories/download_repository.dart';
import 'downloads_state.dart';

class DownloadsController extends StateNotifier<DownloadsState> {
  DownloadsController({
    required DownloadRepository downloadRepository,
  })  : _downloadRepository = downloadRepository,
        super(const DownloadsState());

  final DownloadRepository _downloadRepository;

  Future<void> loadDownloads() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    try {
      final items = await _downloadRepository.listDownloads();
      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load downloaded files.',
      );
    }
  }

  Future<DownloadItem> ensureDownloaded(ResourceItem item) async {
    final ids = <String>{...state.busyResourceIds, item.id};
    state = state.copyWith(
      busyResourceIds: ids,
      errorMessage: null,
    );
    try {
      final downloadItem = await _downloadRepository.ensureDownloaded(item);
      final latest = await _downloadRepository.listDownloads();
      state = state.copyWith(
        busyResourceIds: {...state.busyResourceIds}..remove(item.id),
        items: latest,
      );
      return downloadItem;
    } catch (error) {
      state = state.copyWith(
        busyResourceIds: {...state.busyResourceIds}..remove(item.id),
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteDownload(String resourceId) async {
    final ids = <String>{...state.busyResourceIds, resourceId};
    state = state.copyWith(
      busyResourceIds: ids,
      errorMessage: null,
    );
    try {
      await _downloadRepository.deleteDownload(resourceId);
      final latest = await _downloadRepository.listDownloads();
      state = state.copyWith(
        busyResourceIds: {...state.busyResourceIds}..remove(resourceId),
        items: latest,
      );
    } catch (_) {
      state = state.copyWith(
        busyResourceIds: {...state.busyResourceIds}..remove(resourceId),
        errorMessage: 'Failed to delete file.',
      );
    }
  }
}
