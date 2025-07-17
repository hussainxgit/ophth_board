// lib/core/services/firestore_service.dart
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generic method to get a document
  Future<DocumentSnapshot> getDocument(
    String collectionPath,
    String documentId,
  ) async {
    try {
      return await _db.collection(collectionPath).doc(documentId).get();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getDocument: $e');
        print(stackTrace);
      }
      throw 'Error fetching document: ${e.message}';
    }
  }

  // Generic method to get a collection
  Future<QuerySnapshot> getCollection(String collectionPath) async {
    try {
      return await _db.collection(collectionPath).get();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getCollection: $e');
        print(stackTrace);
      }
      throw 'Error fetching collection: ${e.message}';
    }
  }

  // Enhanced method to get collection with queries
  Future<QuerySnapshot> getCollectionWithQuery(
    String collectionPath, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) async {
    try {
      Query query = _db.collection(collectionPath);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        for (final order in orderBy) {
          query = query.orderBy(order.field, descending: order.descending);
        }
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      if (endBefore != null) {
        query = query.endBeforeDocument(endBefore);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getCollectionWithQuery: $e');
        print(stackTrace);
      }
      throw 'Error fetching collection with query: ${e.message}';
    }
  }

  // Enhanced method to get collection stream with queries
  Stream<QuerySnapshot> getCollectionStreamWithQuery(
    String collectionPath, {
    List<QueryFilter>? filters,
    List<QueryOrder>? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) {
    try {
      Query query = _db.collection(collectionPath);

      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        for (final order in orderBy) {
          query = query.orderBy(order.field, descending: order.descending);
        }
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      if (endBefore != null) {
        query = query.endBeforeDocument(endBefore);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getCollectionStreamWithQuery: $e');
        print(stackTrace);
      }
      throw 'Error streaming collection with query: ${e.message}';
    }
  }

  // Helper method to apply filters
  Query _applyFilter(Query query, QueryFilter filter) {
    // Handle document ID queries specially
    if (filter.field == '__name__' || filter.field == 'documentId') {
      switch (filter.type) {
        case FilterType.isEqualTo:
          return query.where(FieldPath.documentId, isEqualTo: filter.value);
        case FilterType.isNotEqualTo:
          return query.where(FieldPath.documentId, isNotEqualTo: filter.value);
        case FilterType.isLessThan:
          return query.where(FieldPath.documentId, isLessThan: filter.value);
        case FilterType.isLessThanOrEqualTo:
          return query.where(
            FieldPath.documentId,
            isLessThanOrEqualTo: filter.value,
          );
        case FilterType.isGreaterThan:
          return query.where(FieldPath.documentId, isGreaterThan: filter.value);
        case FilterType.isGreaterThanOrEqualTo:
          return query.where(
            FieldPath.documentId,
            isGreaterThanOrEqualTo: filter.value,
          );
        case FilterType.arrayContains:
          return query.where(FieldPath.documentId, arrayContains: filter.value);
        case FilterType.arrayContainsAny:
          return query.where(
            FieldPath.documentId,
            arrayContainsAny: filter.value,
          );
        case FilterType.whereIn:
          return query.where(FieldPath.documentId, whereIn: filter.value);
        case FilterType.whereNotIn:
          return query.where(FieldPath.documentId, whereNotIn: filter.value);
        case FilterType.isNull:
          return query.where(FieldPath.documentId, isNull: true);
        case FilterType.isNotNull:
          return query.where(FieldPath.documentId, isNull: false);
      }
    }

    // Handle regular field queries
    switch (filter.type) {
      case FilterType.isEqualTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case FilterType.isNotEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case FilterType.isLessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case FilterType.isLessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case FilterType.isGreaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case FilterType.isGreaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case FilterType.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case FilterType.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case FilterType.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case FilterType.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
      case FilterType.isNull:
        return query.where(filter.field, isNull: true);
      case FilterType.isNotNull:
        return query.where(filter.field, isNull: false);
    }
  }

  // Generic method to set (create or overwrite) a document
  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _db.collection(collectionPath).add(data);
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - addDocument: $e');
        print(stackTrace);
      }
      throw 'Error adding document: ${e.message}';
    }
  }

  // Method to set a document with specific ID
  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - setDocument: $e');
        print(stackTrace);
      }
      throw 'Error setting document: ${e.message}';
    }
  }

  // Generic method to update a document
  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection(collectionPath).doc(documentId).update(data);
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - updateDocument: $e');
        print(stackTrace);
      }
      throw 'Error updating document: ${e.message}';
    }
  }

  // Generic method to delete a document
  Future<void> deleteDocument(String collectionPath, String documentId) async {
    try {
      await _db.collection(collectionPath).doc(documentId).delete();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - deleteDocument: $e');
        print(stackTrace);
      }
      throw 'Error deleting document: ${e.message}';
    }
  }

  // Method to get a stream of a collection
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    try {
      return _db.collection(collectionPath).snapshots();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getCollectionStream: $e');
        print(stackTrace);
      }
      throw 'Error streaming collection: ${e.message}';
    }
  }

  // Method to get a stream of a document
  Stream<DocumentSnapshot> getDocumentStream(
    String collectionPath,
    String documentId,
  ) {
    try {
      return _db.collection(collectionPath).doc(documentId).snapshots();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getDocumentStream: $e');
        print(stackTrace);
      }
      throw 'Error streaming document: ${e.message}';
    }
  }

  // Batch operations
  WriteBatch batch() => _db.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - commitBatch: $e');
        print(stackTrace);
      }
      throw 'Error committing batch: ${e.message}';
    }
  }

  // Transaction operations
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _db.runTransaction(updateFunction);
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - runTransaction: $e');
        print(stackTrace);
      }
      throw 'Error running transaction: ${e.message}';
    }
  }

  // Method to get multiple documents by their IDs
  Future<List<DocumentSnapshot>> getDocumentsByIds(
    String collectionPath,
    List<String> documentIds,
  ) async {
    try {
      if (documentIds.isEmpty) return [];

      final List<DocumentSnapshot> documents = [];

      // Firestore has a limit of 10 items for whereIn queries
      for (int i = 0; i < documentIds.length; i += 10) {
        final chunk = documentIds.sublist(
          i,
          math.min(i + 10, documentIds.length),
        );

        final querySnapshot = await _db
            .collection(collectionPath)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        documents.addAll(querySnapshot.docs);
      }

      return documents;
    } on FirebaseException catch (e, stackTrace) {
      if (kDebugMode) {
        print('FirestoreService Error - getDocumentsByIds: $e');
        print(stackTrace);
      }
      throw 'Error fetching documents by IDs: ${e.message}';
    }
  }
}

// Query filter class
class QueryFilter {
  final String field;
  final FilterType type;
  final dynamic value;

  const QueryFilter({
    required this.field,
    required this.type,
    required this.value,
  });

  // Convenience constructors
  static QueryFilter isEqualTo(String field, dynamic value) =>
      QueryFilter(field: field, type: FilterType.isEqualTo, value: value);

  static QueryFilter isNotEqualTo(String field, dynamic value) =>
      QueryFilter(field: field, type: FilterType.isNotEqualTo, value: value);

  static QueryFilter isLessThan(String field, dynamic value) =>
      QueryFilter(field: field, type: FilterType.isLessThan, value: value);

  static QueryFilter isLessThanOrEqualTo(String field, dynamic value) =>
      QueryFilter(
        field: field,
        type: FilterType.isLessThanOrEqualTo,
        value: value,
      );

  static QueryFilter isGreaterThan(String field, dynamic value) =>
      QueryFilter(field: field, type: FilterType.isGreaterThan, value: value);

  static QueryFilter isGreaterThanOrEqualTo(String field, dynamic value) =>
      QueryFilter(
        field: field,
        type: FilterType.isGreaterThanOrEqualTo,
        value: value,
      );

  static QueryFilter arrayContains(String field, dynamic value) =>
      QueryFilter(field: field, type: FilterType.arrayContains, value: value);

  static QueryFilter arrayContainsAny(String field, List<dynamic> value) =>
      QueryFilter(
        field: field,
        type: FilterType.arrayContainsAny,
        value: value,
      );

  static QueryFilter whereIn(String field, List<dynamic> value) =>
      QueryFilter(field: field, type: FilterType.whereIn, value: value);

  static QueryFilter whereNotIn(String field, List<dynamic> value) =>
      QueryFilter(field: field, type: FilterType.whereNotIn, value: value);

  static QueryFilter isNull(String field) =>
      QueryFilter(field: field, type: FilterType.isNull, value: null);

  static QueryFilter isNotNull(String field) =>
      QueryFilter(field: field, type: FilterType.isNotNull, value: null);

  // Special constructor for document ID queries
  static QueryFilter documentIdWhereIn(List<String> ids) =>
      QueryFilter(field: '__name__', type: FilterType.whereIn, value: ids);

  static QueryFilter documentIdEqualTo(String id) =>
      QueryFilter(field: '__name__', type: FilterType.isEqualTo, value: id);
}

// Filter types enum
enum FilterType {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
  isNotNull,
}

// Query order class
class QueryOrder {
  final String field;
  final bool descending;

  const QueryOrder({required this.field, this.descending = false});

  static QueryOrder asc(String field) => QueryOrder(field: field);
  static QueryOrder desc(String field) =>
      QueryOrder(field: field, descending: true);
}

// Riverpod provider for the FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
