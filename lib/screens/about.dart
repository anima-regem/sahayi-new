import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'About Sahayi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sahayi is a lightweight frontend for public Google Drive-based study materials.',
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'How it works',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '1. Reads department/semester/subject/category folders.'),
                  Text('2. Lists PDF files from public Google Drive folders.'),
                  Text(
                      '3. Lets users search globally and download offline copies.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Troubleshooting',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                      '• Ensure `DRIVE_API_KEY` and `DRIVE_ROOT_FOLDER_ID` are set.'),
                  Text('• Confirm Drive files/folders are publicly readable.'),
                  Text('• Pull to refresh when new files are uploaded.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
