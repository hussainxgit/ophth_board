/// Enum to represent the status of a content entry.
enum ContentStatus { draft, published, archived, pendingReview }

/// Enum to represent the specific type of content.
/// You can expand this enum as you add more content types.
enum ContentType { announcement, noticeBoard, post }

/// Abstract class representing a generic content entry.
/// This class cannot be instantiated directly but serves as a base for specific content types.
abstract class ContentEntry {
  /// The unique identifier for the content entry.
  final String id;

  /// The title of the content entry.
  String title;

  /// The main body or content of the entry.
  String content;

  /// The author or creator of the content.
  String author; // Or potentially a User object: final User author;

  /// The date and time when the content entry was created.
  final DateTime createdAt;

  /// The date and time when the content entry was last updated.
  DateTime updatedAt;

  /// The current status of the content entry (e.g., draft, published).
  ContentStatus status;

  /// The specific type of content (e.g., news, event).
  final ContentType type;

  /// Constructor for the ContentEntry.
  /// [id], [createdAt], and [type] are typically set once upon creation.
  /// [title], [content], [author], [updatedAt], and [status] can be modified.
  ContentEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.type,
  });

  // --- Common Methods ---

  /// Displays a summary of the content entry.
  /// This is an abstract method, meaning subclasses must provide their own implementation.
  void displaySummary();

  /// Publishes the content entry.
  /// This method might be common, or subclasses might override it for specific logic.
  void publish() {
    if (status == ContentStatus.draft ||
        status == ContentStatus.pendingReview) {
      status = ContentStatus.published;
      updatedAt = DateTime.now();
      print('"$title" has been published.');
    } else {
      print('"$title" cannot be published from status: $status.');
    }
  }

  /// Archives the content entry.
  void archive() {
    if (status == ContentStatus.published) {
      status = ContentStatus.archived;
      updatedAt = DateTime.now();
      print('"$title" has been archived.');
    } else {
      print('"$title" cannot be archived from status: $status.');
    }
  }

  /// A method to get a brief description or excerpt.
  /// Subclasses can override this if they have a more specific way to generate an excerpt.
  String getExcerpt({int maxLength = 100}) {
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }

  /// Method to update the content.
  void updateContent(String newContent, {String? newTitle, String? newAuthor}) {
    content = newContent;
    if (newTitle != null) {
      title = newTitle;
    }
    if (newAuthor != null) {
      author = newAuthor;
    }
    updatedAt = DateTime.now();
    print('Content entry "$title" has been updated.');
  }

  // You could add more common methods here, like:
  // void delete();
  // void addTag(String tag);
  // void removeTag(String tag);
}
