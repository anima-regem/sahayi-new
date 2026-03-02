class AppConfig {
  const AppConfig({
    required this.driveApiKey,
    required this.driveRootFolderId,
  });

  final String driveApiKey;
  final String driveRootFolderId;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      driveApiKey: String.fromEnvironment('DRIVE_API_KEY', defaultValue: ''),
      driveRootFolderId:
          String.fromEnvironment('DRIVE_ROOT_FOLDER_ID', defaultValue: ''),
    );
  }

  bool get isValid =>
      driveApiKey.trim().isNotEmpty && driveRootFolderId.trim().isNotEmpty;

  List<String> get missingFields {
    final missing = <String>[];
    if (driveApiKey.trim().isEmpty) {
      missing.add('DRIVE_API_KEY');
    }
    if (driveRootFolderId.trim().isEmpty) {
      missing.add('DRIVE_ROOT_FOLDER_ID');
    }
    return missing;
  }
}
