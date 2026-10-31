import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_label.dart';

/// Opens when a task is tapped. It receives the [Task] it should show
/// through its constructor.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.store, required this.task});

  final ProjectStore store;
  final Task task;

  void _delete(BuildContext context) {
    // Grab the messenger first: after pop() this screen is gone.
    final messenger = ScaffoldMessenger.of(context);
    store.removeTask(task);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final dueText = task.isDone ? 'Completed' : task.dueLabel;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                ScreenHeader(
                  title: 'Task details',
                  subtitle: dueText,
                  showBack: true,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: task.status == TaskStatus.needsAttention &&
                            !task.isDone
                        ? AppColors.pink
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.title,
                    style: textTheme.titleLarge?.copyWith(
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: task.owner,
                    ),
                    _InfoChip(
                      icon: Icons.flag_outlined,
                      label: task.statusLabel,
                    ),
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: dueText,
                    ),
                  ],
                ),
                const SectionLabel('NOTES'),
                Text(
                  task.notes.isEmpty ? 'No notes for this task yet.' : task.notes,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => store.toggleTask(task),
                    icon: Icon(
                      task.isDone ? Icons.undo_rounded : Icons.check_rounded,
                    ),
                    label: Text(
                      task.isDone ? 'Mark as not done' : 'Mark as complete',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _delete(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete task'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(64, 48),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
