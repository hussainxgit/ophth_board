import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ophth_board/features/content_entries/model/content_entry.dart';

/// Represents an announcement content entry.
class Announcement extends ContentEntry {
  // Add any specific fields for Announcement here if needed in the future.
  // For example:
  // final bool isUrgent;

  /// Constructor for an Announcement.
  Announcement({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.createdAt,
    required super.updatedAt,
    required super.status,
    // this.isUrgent = false, // Example of an Announcement-specific field
  }) : super(
          type: ContentType.announcement, // Ensures type is always announcement
        );

  @override
  void displaySummary() {
    print('--- Announcement ---');
    print('ID: $id');
    print('Title: $title');
    print('Author: $author');
    print('Created: ${createdAt.toIso8601String()}');
    print('Updated: ${updatedAt.toIso8601String()}');
    print('Status: $status');
    // if (isUrgent) {
    //   print('** URGENT **');
    // }
    print('Excerpt: ${getExcerpt(maxLength: 50)}');
    print('--------------------');
  }

  /// Creates a Map representation of this Announcement instance,
  /// suitable for saving to Firestore.
  /// The 'id' is typically handled by the repository/Firestore document ID
  /// and not included in the map data itself.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name, // Store enum as its string name
      'type': type.name,     // Store enum as its string name
      // 'isUrgent': isUrgent, // Example
    };
  }

  /// Creates an Announcement instance from a map (typically from Firestore)
  /// and a document ID.
  factory Announcement.fromMap(Map<String, dynamic> map, String documentId) {
    return Announcement(
      id: documentId,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      author: map['author'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ContentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ContentStatus.draft, // Default if status is missing or invalid
      ),
      // isUrgent: map['isUrgent'] as bool? ?? false, // Example
      // Note: 'type' from the map is ignored here; constructor sets it.
    );
  }

  /// Creates a new Announcement instance with updated fields.
  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    ContentStatus? status,
    // bool? isUrgent, // Example
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      // isUrgent: isUrgent ?? this.isUrgent, // Example
    );
  }
}