import '../models/download_item.dart';

class DownloadsState {
  const DownloadsState({
    this.items = const <DownloadItem>[],
    this.isLoading = false,
    this.errorMessage,
    this.busyResourceIds = const <String>{},
  });

  final List<DownloadItem> items;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> busyResourceIds;

  DownloadsState copyWith({
    List<DownloadItem>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Set<String>? busyResourceIds,
  }) {
    return DownloadsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      busyResourceIds: busyResourceIds ?? this.busyResourceIds,
    );
  }
}

const _sentinel = Object();
