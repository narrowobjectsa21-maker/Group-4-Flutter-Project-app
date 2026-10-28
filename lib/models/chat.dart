/// A team channel (like #q4-launch) or a direct message with one person.
class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.isDirect,
  });

  final String id;
  final String name;

  /// true = chat with one person, false = group channel.
  final bool isDirect;
}

/// One message inside a conversation.
class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });

  final String sender;
  final String text;
  final String time;

  /// true when the message was written by the person using the app.
  final bool isMe;
}
