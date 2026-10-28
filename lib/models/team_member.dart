/// A person on the project team.
class TeamMember {
  const TeamMember({required this.name, required this.role});

  final String name;
  final String role;

  /// Two letters for the avatar, e.g. "Mark" -> "MA", "Ariq Pratama" -> "AP".
  String get initials {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    final single = parts.isEmpty ? '?' : parts[0];
    return (single.length >= 2 ? single.substring(0, 2) : single).toUpperCase();
  }
}
