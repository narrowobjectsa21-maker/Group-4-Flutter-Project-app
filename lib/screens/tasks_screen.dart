import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/task.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/inline_composer.dart';
import '../widgets/orbit_nav_bar.dart';
import '../widgets/orbit_snack_bar.dart';
import '../widgets/pill_chip.dart';
import '../widgets/screen_header.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

enum _TaskTab { today, upcoming, completed }

/// A grey heading inside the task list (for example "NEEDS ATTENTION").
class _SectionHeader {
  const _SectionHeader(this.label, {this.isAlert = false});

  final String label;
  final bool isAlert;
}

/// "My tasks": tasks grouped by Today / Upcoming / Completed.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.store});

  final ProjectStore store;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _TaskTab _tab = _TaskTab.today;
  bool _adding = false;

  /// Builds the list rows: section headers and tasks, in display order.
  List<Object> _buildRows(ProjectStore store) {
    final rows = <Object>[];

    void addGroup(String label, List<Task> items, {bool isAlert = false}) {
      if (items.isEmpty) {
        return;
      }
      rows.add(_SectionHeader(label, isAlert: isAlert));
      rows.addAll(items);
    }

    if (_tab == _TaskTab.today) {
      final today = store.todayTasks;
      addGroup(
        'NEEDS ATTENTION',
        today.where((t) => t.status == TaskStatus.needsAttention).toList(),
        isAlert: true,
      );
      addGroup(
        'IN PROGRESS',
        today.where((t) => t.status == TaskStatus.inProgress).toList(),
      );
      addGroup(
        'TO DO',
        today.where((t) => t.status == TaskStatus.todo).toList(),
      );
    } else if (_tab == _TaskTab.upcoming) {
      final upcoming = store.upcomingTasks
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      addGroup('COMING UP', upcoming);
    } else {
      addGroup('DONE', store.completedTasks);
    }
    return rows;
  }

  String _emptyText() {
    if (_tab == _TaskTab.today) {
      return 'Nothing due today. Enjoy the quiet!';
    } else if (_tab == _TaskTab.upcoming) {
      return 'No upcoming tasks yet.';
    } else {
      return 'No completed tasks yet.';
    }
  }

  String _tabLabel(String name, int count, bool selected) {
    return selected ? '$name  •  $count' : name;
  }

  void _openDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailScreen(store: widget.store, task: task),
      ),
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
            final rows = _buildRows(store);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(
                    title: 'My tasks',
                    subtitle: 'Priorities, owners, and deadlines in one place',
                    showBack: true,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PillChip(
                        label: _tabLabel(
                          'Today',
                          store.todayTasks.length,
                          _tab == _TaskTab.today,
                        ),
                        selected: _tab == _TaskTab.today,
                        onTap: () => setState(() => _tab = _TaskTab.today),
                      ),
                      PillChip(
                        label: _tabLabel(
                          'Upcoming',
                          store.upcomingTasks.length,
                          _tab == _TaskTab.upcoming,
                        ),
                        selected: _tab == _TaskTab.upcoming,
                        onTap: () => setState(() => _tab = _TaskTab.upcoming),
                      ),
                      PillChip(
                        label: _tabLabel(
                          'Completed',
                          store.completedTasks.length,
                          _tab == _TaskTab.completed,
                        ),
                        selected: _tab == _TaskTab.completed,
                        onTap: () => setState(() => _tab = _TaskTab.completed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: rows.isEmpty
                        ? Center(
                            child: Text(
                              _emptyText(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              final row = rows[index];
                              if (row is _SectionHeader) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    row.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: row.isAlert
                                              ? AppColors.danger
                                              : null,
                                        ),
                                  ),
                                );
                              } else {
                                final task = row as Task;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TaskCard(
                                    task: task,
                                    onToggle: () => store.toggleTask(task),
                                    onTap: () => _openDetail(task),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (_adding)
                    InlineComposer(
                      hint: 'What needs to be done?',
                      emptyMessage: 'Please type a task name first.',
                      onSubmit: (title) {
                        store.addTask(title);
                        setState(() {
                          _adding = false;
                          _tab = _TaskTab.today;
                        });
                        showOrbitSnackBar(context, 'Task added to Today');
                      },
                      onCancel: () => setState(() => _adding = false),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _adding = true),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add a task'),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: OrbitNavBar(currentIndex: tasksTab, store: store),
    );
  }
}
