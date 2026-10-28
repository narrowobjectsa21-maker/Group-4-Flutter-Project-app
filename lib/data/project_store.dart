import 'package:flutter/foundation.dart';

import '../models/chat.dart';
import '../models/integration.dart';
import '../models/project_file.dart';
import '../models/task.dart';
import '../models/team_member.dart';

/// Holds all the data of the Orbit project (tasks, files, chats, team).
///
/// One [ProjectStore] is created in `main.dart` and passed to every screen
/// through its constructor. When something changes, the store calls
/// `notifyListeners()` and every screen that is listening rebuilds itself,
/// so the Home screen always shows the same numbers as the Tasks screen.
class ProjectStore extends ChangeNotifier {
  ProjectStore() {
    _seedTasks();
  }

  final String projectName = 'Q4 Marketing Launch';
  final String userName = 'Alex';

  // ---------------------------------------------------------------- Tasks

  final List<Task> _tasks = [];
  int _nextTaskId = 1;

  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Open tasks that are due today (or overdue).
  List<Task> get todayTasks =>
      _tasks.where((task) => !task.isDone && task.isDueToday).toList();

  /// Open tasks that are due after today.
  List<Task> get upcomingTasks =>
      _tasks.where((task) => !task.isDone && !task.isDueToday).toList();

  List<Task> get completedTasks => _tasks.where((task) => task.isDone).toList();

  int get openTaskCount => _tasks.where((task) => !task.isDone).length;

  /// Share of finished tasks from 0.0 to 1.0.
  double get progress {
    if (_tasks.isEmpty) {
      return 0;
    }
    return completedTasks.length / _tasks.length;
  }

  int get progressPercent => (progress * 100).round();

  void addTask(String title, {int dueInDays = 0}) {
    _tasks.add(_makeTask(title, userName, dueInDays: dueInDays));
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  Task _makeTask(
    String title,
    String owner, {
    TaskStatus status = TaskStatus.todo,
    int dueInDays = 0,
    bool done = false,
    String notes = '',
  }) {
    final now = DateTime.now();
    return Task(
      id: _nextTaskId++,
      title: title,
      owner: owner,
      dueDate: DateTime(now.year, now.month, now.day + dueInDays),
      status: status,
      isDone: done,
      notes: notes,
    );
  }

  void _seedTasks() {
    _tasks.addAll([
      // Today
      _makeTask(
        'Review new client feedback',
        'Ariq',
        status: TaskStatus.needsAttention,
        notes: 'Ariq shared the client comments on the banner set. '
            'Read them and reply in the #q4-launch channel.',
      ),
      _makeTask(
        'Approve social media assets',
        'Kamil',
        status: TaskStatus.needsAttention,
        notes: 'Check the final banner sizes for Instagram and LinkedIn '
            'before they are scheduled.',
      ),
      _makeTask(
        'Finalize campaign copy',
        'Nathan',
        status: TaskStatus.inProgress,
        notes: 'Headline and caption text for all launch posts.',
      ),
      _makeTask(
        'Schedule launch post',
        'Khayru',
        status: TaskStatus.inProgress,
        notes: 'Waiting for the approved assets before scheduling.',
      ),
      // Upcoming
      _makeTask('Draft press release', 'Nathan', dueInDays: 2),
      _makeTask('Export final banners', 'Mark', dueInDays: 3),
      _makeTask('Book influencer call', 'Khayru', dueInDays: 5),
      // Completed
      _makeTask('Write campaign brief', 'Nathan', dueInDays: -12, done: true),
      _makeTask('Collect brand assets', 'Mark', dueInDays: -12, done: true),
      _makeTask('Create social banners', 'Mark', dueInDays: -10, done: true),
      _makeTask('Set up #q4-launch channel', 'Kamil', dueInDays: -10, done: true),
      _makeTask('Draft launch timeline', 'Kamil', dueInDays: -9, done: true),
      _makeTask('Pick campaign hashtags', 'Nathan', dueInDays: -9, done: true),
      _makeTask('Design logo lockups', 'Mark', dueInDays: -8, done: true),
      _makeTask('Shoot product photos', 'Khayru', dueInDays: -8, done: true),
      _makeTask('Write ad headlines', 'Nathan', dueInDays: -7, done: true),
      _makeTask('Review brand colours', 'Ariq', dueInDays: -6, done: true),
      _makeTask('Build email template', 'Mark', dueInDays: -5, done: true),
      _makeTask('Plan influencer list', 'Khayru', dueInDays: -4, done: true),
      _makeTask('Approve campaign budget', 'Kamil', dueInDays: -3, done: true),
      _makeTask('Draft client questions', 'Ariq', dueInDays: -2, done: true),
      _makeTask('Share brief with client', 'Kamil', dueInDays: -1, done: true),
    ]);
  }

  // ---------------------------------------------------------------- Files

  final List<ProjectFile> _files = [
    const ProjectFile(
      id: 1,
      name: 'Social_Banners_V3.fig',
      kind: FileKind.design,
      owner: 'Mark',
      updated: '12 min ago',
      isShared: true,
    ),
    const ProjectFile(
      id: 2,
      name: 'Q4_Campaign_Brief.doc',
      kind: FileKind.doc,
      owner: 'Nathan',
      updated: '1 hour ago',
      isShared: true,
    ),
    const ProjectFile(
      id: 3,
      name: 'Client_Feedback.pdf',
      kind: FileKind.pdf,
      owner: 'Ariq',
      updated: 'Yesterday',
      isShared: true,
    ),
    const ProjectFile(
      id: 4,
      name: 'Brand_Guidelines.pdf',
      kind: FileKind.pdf,
      owner: 'Kamil',
      updated: '2 days ago',
    ),
    const ProjectFile(
      id: 5,
      name: 'Logo_Pack.fig',
      kind: FileKind.design,
      owner: 'Mark',
      updated: '3 days ago',
    ),
    const ProjectFile(
      id: 6,
      name: 'Launch_Checklist.doc',
      kind: FileKind.doc,
      owner: 'Khayru',
      updated: 'Last week',
      isShared: true,
    ),
  ];
  int _nextFileId = 7;

  List<ProjectFile> get files => List.unmodifiable(_files);

  /// Adds a file or link. The kind is guessed from the name.
  void addFile(String nameOrLink) {
    final lower = nameOrLink.toLowerCase();
    FileKind kind;
    if (lower.startsWith('http')) {
      kind = FileKind.link;
    } else if (lower.endsWith('.fig')) {
      kind = FileKind.design;
    } else if (lower.endsWith('.pdf')) {
      kind = FileKind.pdf;
    } else {
      kind = FileKind.doc;
    }
    _files.insert(
      0,
      ProjectFile(
        id: _nextFileId++,
        name: nameOrLink,
        kind: kind,
        owner: userName,
        updated: 'Just now',
      ),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------- Chats

  final List<Channel> channels = const [
    Channel(id: 'design-updates', name: 'design-updates', isDirect: false),
    Channel(id: 'q4-launch', name: 'q4-launch', isDirect: false),
    Channel(id: 'ariq', name: 'Ariq Pratama', isDirect: true),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'design-updates': [
      const ChatMessage(
        sender: 'Mark',
        text: 'Uploaded Social_Banners_V3 to Figma.',
        time: '10:05',
      ),
      const ChatMessage(
        sender: 'Mark',
        text: 'Waiting for approval on the banner sizes.',
        time: '10:07',
      ),
    ],
    'q4-launch': [
      const ChatMessage(
        sender: 'Kamil',
        text: 'Launch checklist is updated. Please tick off your items.',
        time: '08:40',
      ),
      const ChatMessage(
        sender: 'Nathan',
        text: 'Campaign copy v2 is almost done.',
        time: '08:52',
      ),
    ],
    'ariq': [
      const ChatMessage(
        sender: 'Ariq',
        text: 'Hey Alex, client feedback is in. Can you take a look?',
        time: '09:12',
      ),
      const ChatMessage(
        sender: 'Alex',
        text: 'Thanks! I will review it before noon.',
        time: '09:15',
        isMe: true,
      ),
    ],
  };

  List<ChatMessage> messagesFor(String channelId) {
    return List.unmodifiable(_messages[channelId] ?? const <ChatMessage>[]);
  }

  /// Text of the latest message, shown under the channel name.
  String previewFor(String channelId) {
    final list = _messages[channelId];
    if (list == null || list.isEmpty) {
      return 'No messages yet';
    }
    return list.last.text;
  }

  void sendMessage(String channelId, String text) {
    final list = _messages.putIfAbsent(channelId, () => []);
    list.add(
      ChatMessage(sender: userName, text: text, time: _timeNow(), isMe: true),
    );
    notifyListeners();
  }

  String _timeNow() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ----------------------------------------------------------------- Team

  final List<TeamMember> _members = [
    const TeamMember(name: 'Kamil', role: 'Project lead'),
    const TeamMember(name: 'Nathan', role: 'Campaign copy'),
    const TeamMember(name: 'Mark', role: 'Design & assets'),
    const TeamMember(name: 'Ariq', role: 'Client feedback'),
    const TeamMember(name: 'Khayru', role: 'Launch operations'),
  ];

  List<TeamMember> get members => List.unmodifiable(_members);

  /// Adds a pending teammate using the part of the email before the "@".
  void inviteMember(String email) {
    final name = email.split('@').first;
    final niceName =
        name.isEmpty ? email : name[0].toUpperCase() + name.substring(1);
    _members.add(TeamMember(name: niceName, role: 'Invited (pending)'));
    notifyListeners();
  }

  final List<Integration> _integrations = [
    Integration(name: 'Figma'),
    Integration(name: 'Google Drive'),
    Integration(name: 'Slack'),
  ];

  List<Integration> get integrations => List.unmodifiable(_integrations);

  void toggleIntegration(Integration integration) {
    integration.isConnected = !integration.isConnected;
    notifyListeners();
  }
}
