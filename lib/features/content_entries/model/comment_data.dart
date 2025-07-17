class CommentData {
  final String? avatarUrl;
  final String name;
  final String dateTime;
  final String text;

  const CommentData({
    this.avatarUrl,
    required this.name,
    required this.dateTime,
    required this.text,
  });

  /// Factory constructor to create a CommentData instance from a map.
  ///
  /// This method is useful for deserializing data from a JSON response or a database.
  factory CommentData.fromMap(Map<String, dynamic> map) {
    return CommentData(
      avatarUrl: map['avatarUrl'] as String?,
      name: map['name'] as String,
      dateTime: map['dateTime'] as String,
      text: map['text'] as String,
    );
  }

  /// Method to convert the CommentData instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'name': name,
      'dateTime': dateTime,
      'text': text,
    };
  }

  /// Create a copy of this CommentData with some modified fields
  CommentData copyWith({
    String? id,
    String? avatarUrl,
    String? name,
    String? dateTime,
    String? text,
  }) {
    return CommentData(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      text: text ?? this.text,
    );
  }
}
