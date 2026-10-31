import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/chat.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/orbit_nav_bar.dart';
import '../widgets/orbit_snack_bar.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_label.dart';

/// "Team chats": pick a channel and read / send messages.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.store});

  final ProjectStore store;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedChannelId = 'ariq';

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      showOrbitSnackBar(context, 'Type a message first.');
    } else {
      widget.store.sendMessage(_selectedChannelId, text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final query = _searchController.text.trim().toLowerCase();
            final channels = store.channels
                .where((channel) => channel.name.toLowerCase().contains(query))
                .toList();
            final messages = store.messagesFor(_selectedChannelId);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(
                    title: 'Team chats',
                    subtitle: 'Project conversations stay with the work',
                    showBack: true,
                  ),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 15, color: AppColors.ink),
                    decoration: orbitInputDecoration(
                      hint: 'Search conversations',
                      prefixIcon: Icons.search_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 68,
                    child: channels.isEmpty
                        ? Center(
                            child: Text(
                              'No conversations found.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: channels.length,
                            itemBuilder: (context, index) {
                              final channel = channels[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _ChannelCard(
                                  channel: channel,
                                  preview: store.previewFor(channel.id),
                                  color: AppColors.pastel(index),
                                  selected: channel.id == _selectedChannelId,
                                  onTap: () => setState(
                                    () => _selectedChannelId = channel.id,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SectionLabel('OPEN CONVERSATION'),
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet. Say hello!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            // reverse: the newest message sits at the bottom,
                            // right above the text field.
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message =
                                  messages[messages.length - 1 - index];
                              return _MessageBubble(message: message);
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                            decoration: orbitInputDecoration(
                              hint: 'Message the team…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _send,
                          tooltip: 'Send',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: OrbitNavBar(currentIndex: chatsTab, store: store),
    );
  }
}

/// A channel or direct message in the horizontal strip.
class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.preview,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Channel channel;
  final String preview;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 190,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.blue : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  channel.isDirect
                      ? Icons.person_outline_rounded
                      : Icons.tag_rounded,
                  size: 20,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One chat bubble. My messages are blue and on the right.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.blue : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.sender,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 11,
                color: isMe ? const Color(0xCCFFFFFF) : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
