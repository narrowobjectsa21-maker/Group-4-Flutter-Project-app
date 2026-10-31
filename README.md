# Group-4-Flutter-Project-app

**Orbit** is a team workspace app: one place for a project's tasks, files, chats and people.
It is the Final Project of Group 4 (Nathan, Ariq, Mark, Kamil and Khayru) and was built from our Figma design.

The demo project inside the app is "Q4 Marketing Launch".

## Screens

| Tab | File | What it does |
| --- | --- | --- |
| Home | `lib/screens/home_screen.dart` | Greeting, project progress, today's tasks, connected tools, quick actions |
| Tasks | `lib/screens/tasks_screen.dart` | Today / Upcoming / Completed tabs, add a task, tick tasks off |
| Task details | `lib/screens/task_detail_screen.dart` | Opens when a task is tapped; complete or delete it |
| Files | `lib/screens/files_screen.dart` | Search and filter files, add a file or link |
| Chats | `lib/screens/chats_screen.dart` | Pick a channel, read and send messages |
| Team | `lib/screens/team_screen.dart` | Members, connected tools, invite a teammate |

## Run it (first time on your laptop)

You need Flutter installed and working (`flutter doctor`), plus Git.

```bash
git clone https://github.com/narrowobjectsa21-maker/group-4-flutter-project-app.git
cd group-4-flutter-project-app

# Creates the android/, ios/, web/ ... folders. Our Dart code in lib/ is kept.
flutter create --project-name orbit --org com.group4 .

flutter pub get
flutter run
```

Run it from Visual Studio Code (press F5) or Android Studio with an emulator, a phone or Chrome.
To run the automatic tests: `flutter test`.

## How the code is organised

```
lib/
  main.dart                  MaterialApp, theme, first screen
  navigation.dart            goToTab(): Navigator.push / pop between the tabs
  theme/app_theme.dart       colours, text styles, button style (one theme for the whole app)
  models/                    Task, ProjectFile, Channel, ChatMessage, TeamMember, Integration
  data/project_store.dart    all demo data + the methods that change it
  screens/                   one file per screen
  widgets/                   small reusable pieces (header, nav bar, task card, ...)
test/                        unit and widget tests
```

## Where each checkpoint requirement is in the code

| Section | Requirement | Where to look |
| --- | --- | --- |
| A | Created with `flutter create`, runs with `flutter run` | steps above |
| B | `MaterialApp` + `Scaffold`, one theme | `lib/main.dart`, `lib/theme/app_theme.dart`, every screen returns a `Scaffold` |
| B | 2+ screens in `lib/screens/`, reachable from Home | the six files in `lib/screens/` |
| B | `Navigator.push` and `Navigator.pop` | `lib/navigation.dart`, `ScreenHeader` back arrow, `TaskDetailScreen._delete` |
| C | `TextField` + `TextEditingController`, disposed, empty input shows a SnackBar | `chats_screen.dart` (`_send`), `files_screen.dart` (search), `widgets/inline_composer.dart` (`_submit`) |
| D | `StatefulWidget` + `setState` | `tasks_screen.dart` (tabs, add button), `files_screen.dart` (filters), `chats_screen.dart` (selected channel) |
| D | Data passed through the constructor | `HomeScreen(store: ...)`, `TaskDetailScreen(store: ..., task: ...)` |
| D | `if` / `else` for a real decision | `home_screen.dart` (`_greeting`), `team_screen.dart` (`_invite`), `models/task.dart` (`dueLabel`) |
| E | `ListView.builder` with `itemCount` + `itemBuilder`, own card design | `tasks_screen.dart`, `files_screen.dart`, `chats_screen.dart`, `team_screen.dart` |
| E | Add an item, open a detail screen on tap | "Add a task" button, tap a task card -> `TaskDetailScreen` |
| F | One shared repo, branches, clear commit messages | see below |

## Working together with Git (Section F)

Every member should make at least one commit from their own account.

1. `git pull` before you start coding, every time.
2. Create your own branch: `git checkout -b yourname/short-description`
3. Make a small change and commit it with a clear message, for example `Changed the task card colour` (not `update` or `fix`).
4. Push your branch: `git push -u origin yourname/short-description`
5. Open a Pull Request on GitHub and ask a teammate to review and merge it.

Small first commits to try: change a colour in `lib/theme/app_theme.dart`, add a task or a team member in `lib/data/project_store.dart`, or improve this README.
