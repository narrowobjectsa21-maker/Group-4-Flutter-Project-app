import 'package:flutter/material.dart';

import 'data/project_store.dart';
import 'screens/chats_screen.dart';
import 'screens/files_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/team_screen.dart';

// Position of each tab in the bottom bar.
const int homeTab = 0;
const int tasksTab = 1;
const int filesTab = 2;
const int chatsTab = 3;
const int teamTab = 4;

Widget _screenFor(int tab, ProjectStore store) {
  switch (tab) {
    case tasksTab:
      return TasksScreen(store: store);
    case filesTab:
      return FilesScreen(store: store);
    case chatsTab:
      return ChatsScreen(store: store);
    case teamTab:
      return TeamScreen(store: store);
    default:
      throw ArgumentError('There is no screen for tab $tab');
  }
}

/// Moves from one tab to another.
///
/// The Home screen is always at the bottom of the stack, so:
///  * Home -> another tab:  Navigator.push (the new screen goes on top)
///  * another tab -> Home:  Navigator.pop  (the screen on top is removed)
///  * tab -> different tab: pushReplacement (swap the screen on top, so the
///    stack never gets longer than Home + one screen)
void goToTab(
  BuildContext context, {
  required ProjectStore store,
  required int from,
  required int to,
}) {
  if (from == to) {
    return;
  }

  if (to == homeTab) {
    Navigator.pop(context);
  } else if (from == homeTab) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _screenFor(to, store)),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _screenFor(to, store)),
    );
  }
}
