import 'package:flutter/material.dart';

class MissingConfigScreen extends StatelessWidget {
  const MissingConfigScreen({
    super.key,
    required this.missingFields,
  });

  final List<String> missingFields;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8EA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration Missing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Set the following --dart-define values before running this app:',
                  ),
                  const SizedBox(height: 10),
                  ...missingFields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $field'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SelectableText(
                    'flutter run --dart-define=DRIVE_API_KEY=YOUR_KEY '
                    '--dart-define=DRIVE_ROOT_FOLDER_ID=YOUR_ROOT_ID',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
