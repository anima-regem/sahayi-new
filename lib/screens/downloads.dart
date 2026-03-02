import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import '../providers/app_providers.dart';
import 'pdf_viewer_screen.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsState = ref.watch(downloadsControllerProvider);
    final controller = ref.read(downloadsControllerProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              children: [
                Text(
                  'Offline Downloads',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDownloads,
              child: downloadsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : downloadsState.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            Center(
                              child: Text(
                                'No downloaded files yet.',
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: downloadsState.items.length,
                          itemBuilder: (context, index) {
                            final item = downloadsState.items[index];
                            final isBusy = downloadsState.busyResourceIds
                                .contains(item.resourceId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.fileName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.pathLabel,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Downloaded ${DateFormat.yMMMd().add_jm().format(item.downloadedAt.toLocal())}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        FilledButton.tonalIcon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => PdfViewerScreen(
                                                  title: item.fileName,
                                                  filePath: item.localPath,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.visibility),
                                          label: const Text('Open'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            await OpenFile.open(item.localPath);
                                          },
                                          icon: const Icon(Icons.open_in_new),
                                          label: const Text('External'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: isBusy
                                              ? null
                                              : () => controller.deleteDownload(
                                                    item.resourceId,
                                                  ),
                                          icon: isBusy
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.delete_outline),
                                          label: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          if (downloadsState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                downloadsState.errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
