import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_service.dart';
import '../../../core/models/result.dart';
import '../../../core/providers/auth_provider.dart';
import '../model/signature.dart';
import '../repositories/signature_repository.dart';

// Repository provider
final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepository(ref.watch(firestoreServiceProvider));
});

// User signature provider (single signature per user)
final userSignatureProvider = FutureProvider<Signature?>((ref) async {
  final currentUser = ref.watch(authProvider).user;
  if (currentUser?.id == null) return null;

  final result = await ref
      .read(signatureRepositoryProvider)
      .getUserSignature(currentUser!.id);
  
  return result.isSuccess ? result.data : null;
});

// Has signature provider
final hasSignatureProvider = FutureProvider<bool>((ref) async {
  final currentUser = ref.watch(authProvider).user;
  if (currentUser?.id == null) return false;

  final result = await ref
      .read(signatureRepositoryProvider)
      .hasSignature(currentUser!.id);
  
  return result.isSuccess ? result.data ?? false : false;
});

// Signature operations
final signatureOperationsProvider =
    NotifierProvider<SignatureOperationsNotifier, SignatureOperationsState>(
      SignatureOperationsNotifier.new,
    );

class SignatureOperationsNotifier extends Notifier<SignatureOperationsState> {
  @override
  SignatureOperationsState build() {
    return const SignatureOperationsState();
  }

  /// Create or update user's signature
  Future<Result<String>> createOrUpdateSignature({
    required String svgData,
  }) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser?.id == null) {
      return Result.error('User not authenticated');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(signatureRepositoryProvider);
      final result = await repository.createOrUpdateSignature(
        userId: currentUser!.id,
        svgData: svgData,
      );

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        // Refresh the signature
        ref.invalidate(userSignatureProvider);
        ref.invalidate(hasSignatureProvider);
      } else {
        state = state.copyWith(isLoading: false, error: result.errorMessage);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return Result.error(e.toString());
    }
  }

  /// Delete user's signature
  Future<Result<void>> deleteUserSignature() async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser?.id == null) {
      return Result.error('User not authenticated');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(signatureRepositoryProvider);
      final result = await repository.deleteUserSignature(currentUser!.id);

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        // Refresh the signature
        ref.invalidate(userSignatureProvider);
        ref.invalidate(hasSignatureProvider);
      } else {
        state = state.copyWith(isLoading: false, error: result.errorMessage);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return Result.error(e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// State class for signature operations
class SignatureOperationsState {
  final bool isLoading;
  final String? error;

  const SignatureOperationsState({
    this.isLoading = false,
    this.error,
  });

  SignatureOperationsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SignatureOperationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Get signature by ID (for single user signature system, this is rarely needed)
final signatureByIdProvider =
    FutureProvider.family<Signature?, String>((ref, signatureId) async {
  final repository = ref.watch(signatureRepositoryProvider);
  final result = await repository.getSignatureById(signatureId);
  
  return result.isSuccess ? result.data : null;
});