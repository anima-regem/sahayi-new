import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/resource_item.dart';
import '../providers/app_providers.dart';
import 'pdf_viewer_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _viewResource(ResourceItem item) async {
    final downloadsController = ref.read(downloadsControllerProvider.notifier);
    try {
      final download = await downloadsController.ensureDownloaded(item);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            title: item.name,
            filePath: download.localPath,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _downloadResource(ResourceItem item) async {
    final downloadsController = ref.read(downloadsControllerProvider.notifier);
    try {
      await downloadsController.ensureDownloaded(item);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${item.name} for offline viewing.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);
    final catalogController = ref.read(catalogControllerProvider.notifier);
    final downloadsState = ref.watch(downloadsControllerProvider);

    final hasSearch = catalogState.searchQuery.trim().isNotEmpty;
    final hasRequiredSelection = catalogState.selectedDepartment != null &&
        catalogState.selectedSemester != null &&
        catalogState.selectedSubject != null;
    final shouldShowSelectPrompt = !hasSearch && !hasRequiredSelection;

    final timeOfDay = DateTime.now().hour >= 12 ? 'afternoon' : 'morning';
    final syncedAt = catalogState.index?.lastSyncedAt.toLocal();
    final syncedAtLabel = syncedAt == null
        ? 'Not synced yet'
        : DateFormat.yMMMd().add_jm().format(syncedAt);

    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good $timeOfDay!',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse your department resources quickly.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last sync: $syncedAtLabel',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: catalogController.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      catalogController.setSearchQuery(value);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search across all files',
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                catalogController.setSearchQuery('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Departments: ${catalogState.departments.length} • Files: ${catalogState.index?.resources.length ?? 0}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          catalogController.clearFilters();
                          setState(() {});
                        },
                        icon: const Icon(Icons.filter_alt_off),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (catalogState.error != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          catalogState.error!.message,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ),
                  if (catalogState.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (!catalogState.isLoading) ...[
                    DropdownButtonFormField<String>(
                      initialValue: catalogState.selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: catalogState.departments
                          .map(
                            (department) => DropdownMenuItem(
                              value: department,
                              child: Text(department),
                            ),
                          )
                          .toList(),
                      onChanged: catalogController.selectDepartment,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: catalogState.selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: catalogState.semesters
                          .map(
                            (semester) => DropdownMenuItem(
                              value: semester,
                              child: Text(semester),
                            ),
                          )
                          .toList(),
                      onChanged: catalogState.selectedDepartment == null
                          ? null
                          : catalogController.selectSemester,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: catalogState.selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: catalogState.subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          )
                          .toList(),
                      onChanged: catalogState.selectedSemester == null
                          ? null
                          : catalogController.selectSubject,
                    ),
                    const SizedBox(height: 12),
                    if (catalogState.categories.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: catalogState.categories
                            .map(
                              (category) => FilterChip(
                                label: Text(category),
                                selected: catalogState.selectedCategories
                                    .contains(category),
                                onSelected: (_) =>
                                    catalogController.toggleCategory(category),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 12),
                    if (catalogState.isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(),
                      ),
                    if (shouldShowSelectPrompt)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'Select Department, Semester, and Subject to view files,\n'
                            'or use Search for global results.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (!shouldShowSelectPrompt &&
                        catalogState.visibleResources.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child:
                              Text('No files found for the selected filters.'),
                        ),
                      ),
                    ...catalogState.visibleResources.map((item) {
                      final isBusy =
                          downloadsState.busyResourceIds.contains(item.id);
                      final subtitle = [
                        item.pathLabel,
                        if (item.sizeBytes != null)
                          _readableSize(item.sizeBytes!),
                        if (item.modifiedTime != null)
                          DateFormat.yMMMd()
                              .format(item.modifiedTime!.toLocal()),
                      ].join(' • ');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed: isBusy
                                        ? null
                                        : () => _viewResource(item),
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View'),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: isBusy
                                        ? null
                                        : () => _downloadResource(item),
                                    icon: isBusy
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.download),
                                    label: const Text('Download'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _readableSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
