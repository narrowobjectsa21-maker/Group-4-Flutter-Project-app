import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../models/integration.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';
import '../widgets/inline_composer.dart';
import '../widgets/orbit_nav_bar.dart';
import '../widgets/orbit_snack_bar.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_label.dart';

/// "Our team": members, roles, connected tools and invitations.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.store});

  final ProjectStore store;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  bool _inviting = false;

  void _invite(String email) {
    // A very simple check: a real address has an "@" and a dot.
    if (!email.contains('@') || !email.contains('.')) {
      showOrbitSnackBar(context, 'That email address does not look right.');
    } else {
      widget.store.inviteMember(email);
      setState(() => _inviting = false);
      showOrbitSnackBar(context, 'Invite sent to $email');
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
            final members = store.members;
            final integrations = store.integrations;
            final textTheme = Theme.of(context).textTheme;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const ScreenHeader(
                  title: 'Our team',
                  subtitle: 'People, ownership, and connected tools',
                  showBack: true,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.projectName,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${members.length} members  •  '
                        '${store.openTaskCount} open tasks',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFAFB8D4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionLabel('TEAM MEMBERS'),
                // The outer ListView scrolls, so this one only takes the
                // space it needs (shrinkWrap) and does not scroll itself.
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pastel(index),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Text(
                                member.initials,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(member.name, style: textTheme.titleMedium),
                                  Text(member.role, style: textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SectionLabel('INTEGRATIONS'),
                for (final integration in integrations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _IntegrationTile(
                      integration: integration,
                      onTap: () => store.toggleIntegration(integration),
                    ),
                  ),
                const SizedBox(height: 10),
                if (_inviting)
                  InlineComposer(
                    hint: 'Teammate email address',
                    emptyMessage: 'Please type an email address first.',
                    keyboardType: TextInputType.emailAddress,
                    sendIcon: Icons.send_rounded,
                    onSubmit: _invite,
                    onCancel: () => setState(() => _inviting = false),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _inviting = true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Invite teammate'),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Group 4  ·  Nathan, Ariq, Mark, and Kamil',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: OrbitNavBar(currentIndex: teamTab, store: store),
    );
  }
}

/// Green tile when a tool is connected, grey when it is not. Tap to toggle.
class _IntegrationTile extends StatelessWidget {
  const _IntegrationTile({required this.integration, required this.onTap});

  final Integration integration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final connected = integration.isConnected;

    return Material(
      color: connected ? AppColors.green : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(integration.name, style: textTheme.titleMedium),
              ),
              Icon(
                connected ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: connected ? AppColors.blue : AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                connected ? 'Connected' : 'Not connected',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
