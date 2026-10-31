import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

/// A coloured card for one task. Tap the circle to complete it,
/// tap the card to open the task details.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  Color _background() {
    if (task.isDone) {
      return AppColors.surface;
    } else if (task.status == TaskStatus.needsAttention) {
      return task.id.isOdd ? AppColors.pink : AppColors.peach;
    } else {
      return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = task.isDone
        ? '${task.owner}  ·  Completed'
        : '${task.owner}  ·  ${task.dueLabel}';

    return Material(
      color: _background(),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: onToggle,
                tooltip: task.isDone ? 'Mark as not done' : 'Mark as done',
                icon: Icon(
                  task.isDone
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isDone ? AppColors.blue : AppColors.ink,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
