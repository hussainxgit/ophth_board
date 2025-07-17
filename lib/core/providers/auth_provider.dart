import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/models/result.dart';
import 'package:ophth_board/core/repositories/auth_repository.dart';
import 'package:ophth_board/core/models/user.dart';
import 'package:ophth_board/core/services/auth_service.dart';

// Auth state model
class AuthState {
  final bool isSignedIn;
  final UserCredentials? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isSignedIn = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  String? get userEmail => user?.email;
  String? get userName => user?.displayName;
  UserRole? get userRole => user?.role;

  AuthState copyWith({
    bool? isSignedIn,
    UserCredentials? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  AuthState clearError() {
    return copyWith(error: null);
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  UserCredentials? currentUser;
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      state = state.copyWith(isSignedIn: true, user: currentUser);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signIn(email: email, password: password);

    if (result.isSuccess) {
      state = state.copyWith(
        isSignedIn: true,
        user: result.data,
        isLoading: false,
      );
      currentUser = result.data;
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.signOut();

    if (result.isSuccess) {
      state = const AuthState();
    } else {
      state = state.copyWith(isLoading: false, error: result.errorMessage);
    }
  }

  void clearError() {
    state = state.clearError();
  }

  Future<Result<UserCredentials>> createAccount({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.createAccount(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      phoneNumber: phoneNumber,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isSignedIn: true,
        user: result.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }

    return result;
  }

}

// Providers

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthService(repository);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<UserCredentials?>((ref) {
  return ref.watch(authProvider).user;
});