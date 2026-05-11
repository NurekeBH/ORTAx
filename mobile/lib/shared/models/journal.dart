class Journal {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String gradeLevel;
  final String? coverAssetPath;
  final List<JournalPage> pages;

  const Journal({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.gradeLevel,
    this.coverAssetPath,
    required this.pages,
  });
}

class JournalPage {
  final int number;
  final String? imageAssetPath;
  final String? text;
  final String? arMarkerId;

  const JournalPage({
    required this.number,
    this.imageAssetPath,
    this.text,
    this.arMarkerId,
  });
}
