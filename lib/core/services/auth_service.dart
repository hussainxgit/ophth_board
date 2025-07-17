import 'package:ophth_board/core/repositories/auth_repository.dart';
import 'package:ophth_board/core/models/user.dart';
import 'package:ophth_board/core/models/result.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<Result<UserCredentials>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return Result.error('Email and password are required');
      }

      if (!_isValidEmail(email)) {
        return Result.error('Please enter a valid email address');
      }

      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        return Result.success(user);
      } else {
        return Result.error('Authentication failed');
      }
    } catch (e) {
      if (e.toString().contains('Invalid email or password')) {
        return Result.error('Invalid email or password');
      }
      print('${e.runtimeType} - ${e.toString()}');
      return Result.error('Sign in failed: ${e.toString()}');
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _authRepository.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.error('Sign out failed: ${e.toString()}');
    }
  }

  Future<UserCredentials?> getCurrentUser() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  Stream<UserCredentials?> get authStateChanges => _authRepository.authStateChanges;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<Result<UserCredentials>> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
        return Result.error('All required fields must be filled');
      }

      if (!_isValidEmail(email)) {
        return Result.error('Please enter a valid email address');
      }

      if (password.length < 6) {
        return Result.error('Password must be at least 6 characters long');
      }

      final user = await _authRepository.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
      );

      if (user != null) {
        return Result.success(user);
      } else {
        return Result.error('Account creation failed');
      }
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}