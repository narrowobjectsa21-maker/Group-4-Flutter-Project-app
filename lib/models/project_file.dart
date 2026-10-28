/// What kind of thing a project file is.
enum FileKind { design, doc, pdf, link }

/// A file or link shared in the project (named ProjectFile so it does not
/// clash with Dart's own `File` class).
class ProjectFile {
  const ProjectFile({
    required this.id,
    required this.name,
    required this.kind,
    required this.owner,
    required this.updated,
    this.isShared = false,
  });

  final int id;
  final String name;
  final FileKind kind;
  final String owner;

  /// Human-friendly text such as "12 min ago".
  final String updated;
  final bool isShared;

  String get kindLabel {
    return switch (kind) {
      FileKind.design => 'Design file',
      FileKind.doc => 'Document',
      FileKind.pdf => 'PDF',
      FileKind.link => 'Link',
    };
  }
}
