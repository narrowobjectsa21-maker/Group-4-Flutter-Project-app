import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/data/project_store.dart';

void main() {
  group('ProjectStore', () {
    test('starts with demo tasks and a progress value', () {
      final store = ProjectStore();

      expect(store.todayTasks.length, 4);
      expect(store.upcomingTasks.length, 3);
      expect(store.progressPercent, 68);
    });

    test('completing a task raises the progress', () {
      final store = ProjectStore();
      final before = store.completedTasks.length;

      store.toggleTask(store.todayTasks.first);

      expect(store.completedTasks.length, before + 1);
      expect(store.todayTasks.length, 3);
    });

    test('a new task shows up in Today', () {
      final store = ProjectStore();

      store.addTask('Write report');

      expect(store.todayTasks.length, 5);
      expect(store.todayTasks.last.title, 'Write report');
    });

    test('a sent message is added to the channel', () {
      final store = ProjectStore();

      store.sendMessage('ariq', 'Hello team');

      expect(store.messagesFor('ariq').last.text, 'Hello team');
      expect(store.messagesFor('ariq').last.isMe, isTrue);
    });

    test('inviting a teammate adds a pending member', () {
      final store = ProjectStore();
      final before = store.members.length;

      store.inviteMember('sam@example.com');

      expect(store.members.length, before + 1);
      expect(store.members.last.name, 'Sam');
    });

    test('adding a file guesses its kind from the name', () {
      final store = ProjectStore();

      store.addFile('Moodboard.fig');

      expect(store.files.first.name, 'Moodboard.fig');
      expect(store.files.first.kind.name, 'design');
    });
  });
}
