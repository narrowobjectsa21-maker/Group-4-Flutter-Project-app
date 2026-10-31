import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/task.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/inline_composer.dart';
import '../widgets/orbit_nav_bar.dart';
import '../widgets/orbit_snack_bar.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_label.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

/// Which quick action is open at the bottom of the Home screen.
enum _QuickAction { none, createTask, uploadFile }

/// The first screen: project progress, today's tasks and quick actions.
/// Every other screen can be reached from here.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  /// The shared project data, passed in through the constructor.
  final ProjectStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _QuickAction _action = _QuickAction.none;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _closeAction() {
    setState(() => _action = _QuickAction.none);
  }

  void _openTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailScreen(store: widget.store, task: task),
      ),
    );
  }

  Widget _buildActionArea() {
    switch (_action) {
      case _QuickAction.createTask:
        return InlineComposer(
          hint: 'What needs to be done today?',
          emptyMessage: 'Please type a task name first.',
          onSubmit: (title) {
            widget.store.addTask(title);
            _closeAction();
            showOrbitSnackBar(context, 'Task added to Today');
          },
          onCancel: _closeAction,
        );
      case _QuickAction.uploadFile:
        return InlineComposer(
          hint: 'File name or link, e.g. Moodboard.fig',
          emptyMessage: 'Please type a file name or link first.',
          sendIcon: Icons.upload_rounded,
          onSubmit: (name) {
            widget.store.addFile(name);
            _closeAction();
            showOrbitSnackBar(context, 'Added to Project files');
          },
          onCancel: _closeAction,
        );
      case _QuickAction.none:
        return _ActionBar(
          onCreateTask: () => setState(() => _action = _QuickAction.createTask),
          onUploadFile: () => setState(() => _action = _QuickAction.uploadFile),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      body: SafeArea(
        // Rebuilds this part of the screen whenever the store changes.
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final todayTasks = store.todayTasks;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                ScreenHeader(
                  title: '${_greeting()}, ${store.userName}',
                  subtitle: '${store.projectName}  •  Your team at a glance',
                ),
                _ProjectBanner(store: store),
                const SectionLabel('TODAY'),
                if (todayTasks.isEmpty)
                  Text(
                    'You are all caught up for today.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  for (final task in todayTasks.take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCard(
                        task: task,
                        onToggle: () => store.toggleTask(task),
                        onTap: () => _openTask(task),
                      ),
                    ),
                if (todayTasks.length > 2)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => goToTab(
                        context,
                        store: store,
                        from: homeTab,
                        to: tasksTab,
                      ),
                      child: Text('See all ${todayTasks.length} tasks'),
                    ),
                  ),
                const SectionLabel('CONNECTED TOOLS'),
                Row(
                  children: [
                    Expanded(
                      child: _ToolTile(
                        name: 'Figma',
                        detail: 'Social banners',
                        color: AppColors.lavender,
                        onTap: () => goToTab(
                          context,
                          store: store,
                          from: homeTab,
                          to: filesTab,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ToolTile(
                        name: 'Drive',
                        detail: 'Campaign brief',
                        color: AppColors.sky,
                        onTap: () => goToTab(
                          context,
                          store: store,
                          from: homeTab,
                          to: filesTab,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ToolTile(
                        name: 'Slack',
                        detail: '#design-updates',
                        color: AppColors.mint,
                        onTap: () => goToTab(
                          context,
                          store: store,
                          from: homeTab,
                          to: chatsTab,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildActionArea(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: OrbitNavBar(currentIndex: homeTab, store: store),
    );
  }
}

/// Dark card with the project name and how far along it is.
class _ProjectBanner extends StatelessWidget {
  const _ProjectBanner({required this.store});

  final ProjectStore store;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusText = store.progress >= 0.5 ? 'On track' : 'Needs a push';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.projectName.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFFAFB8D4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$statusText  •  ${store.progressPercent}% complete',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: store.progress,
              minHeight: 6,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small coloured tile for a connected tool. Tapping it opens a related tab.
class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.name,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The blue bar with "Create task" and "Upload file".
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onCreateTask, required this.onUploadFile});

  final VoidCallback onCreateTask;
  final VoidCallback onUploadFile;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create task'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: style,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          TextButton.icon(
            onPressed: onUploadFile,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Upload file'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: style,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
