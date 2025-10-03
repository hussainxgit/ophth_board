/// Enum to represent the status of a content entry.
enum ContentStatus { draft, published, archived, pendingReview }

/// Enum to represent the specific type of content.
/// You can expand this enum as you add more content types.
enum ContentType { announcement, noticeBoard, post }

/// Enum to represent the priority level of a content entry.
enum ContentPriority { low, normal, high, urgent }

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
  String author;
  
  /// The unique identifier of the author.
  final String authorId;

  /// The date and time when the content entry was created.
  final DateTime createdAt;

  /// The date and time when the content entry was last updated.
  DateTime updatedAt;

  /// The current status of the content entry (e.g., draft, published).
  ContentStatus status;

  /// The specific type of content (e.g., news, event).
  final ContentType type;

  /// The priority level of the content entry.
  ContentPriority priority;

  /// List of tags associated with the content entry.
  List<String> tags;

  /// Number of views this content has received.
  int viewCount;

  /// Number of likes this content has received.
  int likeCount;

  /// List of user IDs who liked this content.
  List<String> likedBy;

  /// Whether comments are enabled for this content.
  bool commentsEnabled;

  /// Constructor for the ContentEntry.
  /// [id], [createdAt], and [type] are typically set once upon creation.
  /// [title], [content], [author], [updatedAt], and [status] can be modified.
  ContentEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.type,
    this.priority = ContentPriority.normal,
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.likedBy = const [],
    this.commentsEnabled = true,
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

  /// Increment the view count.
  void incrementViewCount() {
    viewCount++;
  }

  /// Toggle like status for a user.
  bool toggleLike(String userId) {
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
      likeCount = likedBy.length;
      return false; // Unliked
    } else {
      likedBy.add(userId);
      likeCount = likedBy.length;
      return true; // Liked
    }
  }

  /// Check if a user has liked this content.
  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  /// Add a tag to the content entry.
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
      updatedAt = DateTime.now();
    }
  }

  /// Remove a tag from the content entry.
  void removeTag(String tag) {
    if (tags.remove(tag)) {
      updatedAt = DateTime.now();
    }
  }

  /// Check if the current user can edit this content.
  bool canEdit(String currentUserId) {
    return authorId == currentUserId;
  }

  /// Check if the current user can delete this content.
  bool canDelete(String currentUserId) {
    return authorId == currentUserId;
  }

  /// Get the time elapsed since creation in a human-readable format.
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get the status display text.
  String getStatusDisplayText() {
    switch (status) {
      case ContentStatus.draft:
        return 'Draft';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.archived:
        return 'Archived';
      case ContentStatus.pendingReview:
        return 'Pending Review';
    }
  }

  /// Get the priority display text.
  String getPriorityDisplayText() {
    switch (priority) {
      case ContentPriority.low:
        return 'Low';
      case ContentPriority.normal:
        return 'Normal';
      case ContentPriority.high:
        return 'High';
      case ContentPriority.urgent:
        return 'Urgent';
    }
  }

  // You could add more common methods here, like:
  // void delete();
  // bool canComment(String userId);
  // void setCommentEnabled(bool enabled);
}
