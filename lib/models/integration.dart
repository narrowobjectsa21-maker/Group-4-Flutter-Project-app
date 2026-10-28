/// A connected tool such as Figma, Google Drive or Slack.
class Integration {
  Integration({required this.name, this.isConnected = true});

  final String name;

  /// Changes when the user taps the tool on the Team screen.
  bool isConnected;
}
