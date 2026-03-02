enum AppErrorType {
  missingConfig,
  network,
  quotaExceeded,
  malformedStructure,
  emptyData,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
  });

  final AppErrorType type;
  final String message;

  @override
  String toString() => message;
}
