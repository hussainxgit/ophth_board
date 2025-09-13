import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ophth_board/core/models/user.dart';
import '../../features/resident/model/resident.dart';
import '../../features/supervisor/model/supervisor.dart';

abstract class AuthRepository {
  Future<UserCredentials?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
  Future<UserCredentials?> getCurrentUser();
  Stream<UserCredentials?> get authStateChanges;
  Future createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
  }) async {}
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserCredentials?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print('User signed in: ${userCredential.user!.uid}');
        return await _getUserData(userCredential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw Exception('Invalid email or password.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception(
            'Too many failed login attempts. Please try again later.',
          );
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserCredentials?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  @override
  Stream<UserCredentials?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        return await _getUserData(user.uid);
      }
      return null;
    });
  }

  Future<UserCredentials?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = uid; // Ensure ID is set
        return _createUserFromData(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  UserCredentials _createUserFromData(Map<String, dynamic> data) {
    switch (data['role']) {
      case 'resident':
        return Resident(
          id: data['id'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          pgy: data['pgy'] ?? '1',
          profileImageUrl: data['profileImageUrl'],
          phoneNumber: data['phoneNumber'],
          isActive: data['isActive'] ?? true,
          civilId: data['civilId'] ?? '',
          workingPlace: data['workingPlace'] ?? '',
          fileNumber: data['fileNumber'] ?? '',
        );
      case 'supervisor':
        return Supervisor(
          id: data['id'],
          email: data['email'],
          firstName: data['firstName'],
          lastName: data['lastName'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          assignedResidents: Map<String, bool>.from(
            data['assignedResidents'] ?? {},
          ),
          activeRotations: Map<String, bool>.from(
            data['activeRotations'] ?? {},
          ),
          profileImageUrl: data['profileImageUrl'],
          phoneNumber: data['phoneNumber'],
          isActive: data['isActive'] ?? true,
          civilId: data['civilId'] ?? '',
          workingPlace: data['workingPlace'] ?? '',
          fileNumber: data['fileNumber'] ?? '',
        );
      default:
        throw Exception('Unknown user role: ${data['role']}');
    }
  }

  @override
  Future<UserCredentials?> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userData = {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'phoneNumber': phoneNumber,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add role-specific fields
        if (role == 'resident') {
          userData['pgy'] = '1';
        } else if (role == 'supervisor') {
          userData['assignedResidents'] = {};
          userData['activeRotations'] = {};
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        return await _getUserData(userCredential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak.');
        case 'email-already-in-use':
          throw Exception('The account already exists for that email.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        default:
          throw Exception('Account creation failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }
}
