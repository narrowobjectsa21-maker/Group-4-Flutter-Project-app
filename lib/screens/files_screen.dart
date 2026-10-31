import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/project_file.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/inline_composer.dart';
import '../widgets/orbit_nav_bar.dart';
import '../widgets/orbit_snack_bar.dart';
import '../widgets/pill_chip.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_label.dart';

enum _FileFilter { all, design, docs, shared }

/// "Project files": search, filter and add the latest files and links.
class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key, required this.store});

  final ProjectStore store;

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  _FileFilter _filter = _FileFilter.all;
  bool _adding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Files that match both the search text and the selected filter chip.
  List<ProjectFile> _visibleFiles(ProjectStore store) {
    final query = _searchController.text.trim().toLowerCase();

    return store.files.where((file) {
      final matchesQuery =
          query.isEmpty || file.name.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _FileFilter.all => true,
        _FileFilter.design => file.kind == FileKind.design,
        _FileFilter.docs =>
          file.kind == FileKind.doc || file.kind == FileKind.pdf,
        _FileFilter.shared => file.isShared,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _showDetails(ProjectFile file) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '${file.kindLabel}  ·  ${file.owner}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated ${file.updated}'
                  '${file.isShared ? '  ·  Shared with the team' : ''}',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final files = _visibleFiles(store);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const ScreenHeader(
                  title: 'Project files',
                  subtitle: 'Find the latest asset without switching apps',
                  showBack: true,
                ),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 15, color: AppColors.ink),
                  decoration: orbitInputDecoration(
                    hint: 'Search files, links, and folders',
                    prefixIcon: Icons.search_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PillChip(
                      label: 'All files',
                      selected: _filter == _FileFilter.all,
                      onTap: () => setState(() => _filter = _FileFilter.all),
                    ),
                    PillChip(
                      label: 'Design',
                      selected: _filter == _FileFilter.design,
                      onTap: () => setState(() => _filter = _FileFilter.design),
                    ),
                    PillChip(
                      label: 'Docs',
                      selected: _filter == _FileFilter.docs,
                      onTap: () => setState(() => _filter = _FileFilter.docs),
                    ),
                    PillChip(
                      label: 'Shared',
                      selected: _filter == _FileFilter.shared,
                      onTap: () => setState(() => _filter = _FileFilter.shared),
                    ),
                  ],
                ),
                const SectionLabel('RECENTLY UPDATED'),
                if (files.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No files match your search.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  // The outer ListView scrolls, so this one only takes the
                  // space it needs (shrinkWrap) and does not scroll itself.
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _FileCard(
                          file: file,
                          onTap: () => _showDetails(file),
                        ),
                      );
                    },
                  ),
                const SectionLabel('CONNECTED SOURCES'),
                Row(
                  children: [
                    for (final name in const ['Figma', 'Drive', 'Slack'])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _SourceTile(
                            name: name,
                            onTap: () => showOrbitSnackBar(
                              context,
                              'Demo only: this would open $name.',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_adding)
                  InlineComposer(
                    hint: 'File name or link, e.g. Moodboard.fig',
                    emptyMessage: 'Please type a file name or link first.',
                    sendIcon: Icons.upload_rounded,
                    onSubmit: (name) {
                      store.addFile(name);
                      setState(() {
                        _adding = false;
                        _filter = _FileFilter.all;
                        _searchController.clear();
                      });
                      showOrbitSnackBar(context, 'Added to Project files');
                    },
                    onCancel: () => setState(() => _adding = false),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _adding = true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Upload or link a file'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: OrbitNavBar(currentIndex: filesTab, store: store),
    );
  }
}

/// One file in the list. The colour and icon depend on the file kind.
class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.onTap});

  final ProjectFile file;
  final VoidCallback onTap;

  Color get _tint => switch (file.kind) {
        FileKind.design => AppColors.lavender,
        FileKind.doc => AppColors.sky,
        FileKind.pdf => AppColors.mint,
        FileKind.link => AppColors.peach,
      };

  IconData get _icon => switch (file.kind) {
        FileKind.design => Icons.palette_outlined,
        FileKind.doc => Icons.description_outlined,
        FileKind.pdf => Icons.picture_as_pdf_outlined,
        FileKind.link => Icons.link_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: _tint,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(_icon, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${file.owner}  ·  ${file.updated}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (file.isShared)
                const Icon(Icons.people_outline, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined tile for a connected source such as Figma.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const Icon(
                Icons.north_east_rounded,
                size: 14,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
