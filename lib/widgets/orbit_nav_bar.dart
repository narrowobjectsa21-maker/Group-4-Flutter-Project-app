import 'package:flutter/material.dart';

import '../data/project_store.dart';
import '../navigation.dart';
import '../theme/app_theme.dart';

/// The bottom bar with the five tabs: Home, Tasks, Files, Chats, Team.
/// Tapping a tab calls [goToTab], which uses Navigator.push / pop.
class OrbitNavBar extends StatelessWidget {
  const OrbitNavBar({
    super.key,
    required this.currentIndex,
    required this.store,
  });

  final int currentIndex;
  final ProjectStore store;

  static const List<_NavDestination> _destinations = [
    _NavDestination('Home', Icons.home_outlined, Icons.home_rounded),
    _NavDestination('Tasks', Icons.check_circle_outline, Icons.check_circle),
    _NavDestination('Files', Icons.folder_outlined, Icons.folder),
    _NavDestination('Chats', Icons.chat_bubble_outline, Icons.chat_bubble),
    _NavDestination('Team', Icons.group_outlined, Icons.group),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < _destinations.length; i++)
                Expanded(
                  child: _NavButton(
                    destination: _destinations[i],
                    selected: i == currentIndex,
                    onTap: () => goToTab(
                      context,
                      store: store,
                      from: currentIndex,
                      to: i,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.blue : AppColors.muted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
