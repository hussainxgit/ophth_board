import 'package:cloud_firestore/cloud_firestore.dart';

import 'content_entry.dart';

class Post extends ContentEntry {
  final String authorId;
  final List<String> tags;

  Post({
    required super.id,
    required super.title,
    required super.content,
    required this.authorId,
    required super.author,
    required super.createdAt,
    required super.updatedAt,
    required super.status,
    this.tags = const [],
  }) : super(
         type: ContentType.post,
       );

  @override
  void displaySummary() {
    print('Post: $title');
    print('Author: $author');
    print('Status: $status');
    print('Created: $createdAt');
    print('Tags: ${tags.join(', ')}');
    print('Excerpt: ${getExcerpt()}');
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    ContentStatus? status,
    List<String>? tags,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.toString().split('.').last,
      'tags': tags,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json, {String? id}) {
    return Post(
      id: id ?? json['id'] as String? ?? '',
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      status: ContentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ContentStatus.draft,
      ),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post.fromJson(data, id: doc.id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          authorId == other.authorId &&
          author == other.author &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          status == other.status &&
          List.from(tags).toString() == List.from(other.tags).toString();

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      authorId.hashCode ^
      author.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      status.hashCode ^
      tags.hashCode;

  @override
  String toString() {
    return 'Post(id: $id, title: $title, content: $content, authorId: $authorId, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, tags: $tags)';
  }
}
