class CommentData {
  final String id;
  final String? avatarUrl;
  final String name;
  final String userId;
  final String dateTime;
  final String? editedAt;
  final String text;
  final bool isEdited;

  const CommentData({
    required this.id,
    this.avatarUrl,
    required this.name,
    required this.userId,
    required this.dateTime,
    this.editedAt,
    required this.text,
    this.isEdited = false,
  });

  /// Factory constructor to create a CommentData instance from a map.
  ///
  /// This method is useful for deserializing data from a JSON response or a database.
  factory CommentData.fromMap(Map<String, dynamic> map) {
    return CommentData(
      id: map['id'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      name: map['name'] as String,
      userId: map['userId'] as String? ?? '',
      dateTime: map['dateTime'] as String,
      editedAt: map['editedAt'] as String?,
      text: map['text'] as String,
      isEdited: map['isEdited'] as bool? ?? false,
    );
  }

  /// Method to convert the CommentData instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatarUrl': avatarUrl,
      'name': name,
      'userId': userId,
      'dateTime': dateTime,
      'editedAt': editedAt,
      'text': text,
      'isEdited': isEdited,
    };
  }

  /// Create a copy of this CommentData with some modified fields
  CommentData copyWith({
    String? id,
    String? avatarUrl,
    String? name,
    String? userId,
    String? dateTime,
    String? editedAt,
    String? text,
    bool? isEdited,
  }) {
    return CommentData(
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      editedAt: editedAt ?? this.editedAt,
      text: text ?? this.text,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  /// Check if the current user can edit this comment
  bool canEdit(String currentUserId) {
    return userId == currentUserId;
  }

  /// Check if the current user can delete this comment
  bool canDelete(String currentUserId) {
    return userId == currentUserId;
  }

  /// Get display time showing edit status
  String getDisplayTime() {
    if (isEdited && editedAt != null) {
      return 'Edited ${_formatDateTime(editedAt!)}';
    }
    return _formatDateTime(dateTime);
  }

  /// Format datetime for display
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CommentData(id: $id, name: $name, text: $text, isEdited: $isEdited)';
  }
}
