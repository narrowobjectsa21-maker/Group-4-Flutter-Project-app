/// How urgent a task is. Used to group tasks on the "My tasks" screen.
enum TaskStatus { needsAttention, inProgress, todo }

/// One task in the project (for example "Review new client feedback").
class Task {
  Task({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueDate,
    this.status = TaskStatus.todo,
    this.isDone = false,
    this.notes = '',
  });

  final int id;
  final String title;
  final String owner;
  final DateTime dueDate;
  final TaskStatus status;
  final String notes;

  /// Changes when the user taps the circle next to a task.
  bool isDone;

  static DateTime _dateOnly(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Calendar days until the task is due (0 = today, negative = overdue).
  int get daysUntilDue =>
      _dateOnly(dueDate).difference(_dateOnly(DateTime.now())).inDays;

  bool get isDueToday => daysUntilDue <= 0;

  String get dueLabel {
    final days = daysUntilDue;
    if (days < 0) {
      return 'Overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $days days';
    }
  }

  String get statusLabel {
    if (isDone) {
      return 'Done';
    }
    return switch (status) {
      TaskStatus.needsAttention => 'Needs attention',
      TaskStatus.inProgress => 'In progress',
      TaskStatus.todo => 'To do',
    };
  }
}
