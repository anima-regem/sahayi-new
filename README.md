# Sahayi

Sahayi is a Flutter app for browsing public Google Drive study materials and
saving PDFs for offline access.

## What It Does

- Loads a catalog from a configured Google Drive root folder.
- Supports global search across file name and metadata.
- Supports drill-down filters: `Department -> Semester -> Subject -> Category`.
- Allows viewing PDFs in-app and opening them in external apps.
- Downloads and caches files locally for offline usage.
- Caches catalog metadata locally using Hive for faster startup.

## Prerequisites

- Flutter SDK (Dart `>=3.0.0 <4.0.0`)
- A Google Drive API key
- A public Google Drive root folder ID containing your material hierarchy

## Configure And Run

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app with required config:

```bash
flutter run \
  --dart-define=DRIVE_API_KEY=YOUR_KEY \
  --dart-define=DRIVE_ROOT_FOLDER_ID=YOUR_ROOT_FOLDER_ID
```

If either value is missing, the app shows a configuration error screen with the
required command.

## Expected Drive Structure

The crawler expects folders in this order and indexes only PDF files at the
category level:

```text
Root Folder
└── Department
    └── Semester
        └── Subject
            └── Category
                └── *.pdf
```

## Development

- Run tests: `flutter test`
- Static analysis: `flutter analyze`

## Notes

- Google Drive files/folders must be publicly readable for API listing and
  downloads to work.
- Pull to refresh in the catalog screen after new files are added to Drive.
