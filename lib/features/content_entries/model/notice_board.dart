import 'package:ophth_board/features/content_entries/model/comment_data.dart';
import 'package:ophth_board/features/content_entries/model/content_entry.dart';

class NoticeBoard extends ContentEntry {
  List<CommentData> comments;
  @override
  List<String> tags;
  NoticeBoard({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.createdAt,
    DateTime? updatedAt,
    this.comments = const [],
    this.tags = const [],
    super.status = ContentStatus.draft,
  }) : super(
         updatedAt: updatedAt ?? DateTime.now(),
         type: ContentType.noticeBoard,
         authorId: author, // Pass author as authorId, or adjust as needed
       );

  /// Factory constructor to create a NoticeBoard instance from a map.
  factory NoticeBoard.fromMap(Map<String, dynamic> map, String id) {
    return NoticeBoard(
      id: id,
      title: map['title'] as String,
      content: map['content'] as String,
      author: map['author'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      comments:
          (map['comments'] as List<dynamic>?)
              ?.map(
                (e) => CommentData.fromMap(
                  e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      status: ContentStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ContentStatus.draft,
      ),
    );
  }

  /// Method to convert the NoticeBoard instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'comments': comments.map((e) => e.toMap()).toList(),
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  /// Method to create a copy of the NoticeBoard instance with optional new values.
  NoticeBoard copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CommentData>? comments,
    List<String>? tags,
    ContentStatus? status,
  }) {
    return NoticeBoard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      status: status ?? this.status,
    );
  }

  @override
  void displaySummary() {
    // TODO: implement displaySummary
  }
}
