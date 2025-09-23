import 'package:cloud_firestore/cloud_firestore.dart';

class Signature {
  final String id;
  final String userId;
  final String signatureStoragePath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Signature({
    required this.id,
    required this.userId,
    required this.signatureStoragePath,
    required this.createdAt,
    this.updatedAt,
  });

  factory Signature.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Signature(
      id: doc.id,
      userId: data['userId'] ?? '',
      signatureStoragePath: data['signatureStoragePath'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'signatureStoragePath': signatureStoragePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Signature copyWith({
    String? id,
    String? userId,
    String? signatureStoragePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Signature(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      signatureStoragePath: signatureStoragePath ?? this.signatureStoragePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Signature &&
        other.id == id &&
        other.userId == userId &&
        other.signatureStoragePath == signatureStoragePath &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        signatureStoragePath.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Signature(id: $id, userId: $userId, createdAt: $createdAt)';
  }
}