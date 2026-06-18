import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({
    this.currentUser,
    this.tokenData,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserProfile? currentUser;
  final Map<String, dynamic>? tokenData;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => currentUser != null;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  AuthState copyWith({
    UserProfile? currentUser,
    Map<String, dynamic>? tokenData,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearTokenData = false,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : currentUser ?? this.currentUser,
      tokenData: clearTokenData ? null : tokenData ?? this.tokenData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login({
    required String username,
    required String password,
    int expiresInMinutes = 30,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(loginUseCaseProvider).call(
      username: username,
      password: password,
      expiresInMinutes: expiresInMinutes,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(currentUser: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to sign in.',
    );
  }

  Future<void> getCurrentUser(String accessToken) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getCurrentUserUseCaseProvider).call(
      accessToken,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(currentUser: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load current user.',
    );
  }

  Future<void> refreshToken({
    required String refreshToken,
    int expiresInMinutes = 30,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(refreshTokenUseCaseProvider).call(
      refreshToken: refreshToken,
      expiresInMinutes: expiresInMinutes,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(tokenData: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to refresh session.',
    );
  }

  Future<void> updateLocalProfile(UserProfile profile) async {
    if (state.currentUser == null) {
      state = state.copyWith(
        errorMessage: 'Sign in before updating profile details.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Temporary local/session profile update until profile mutation APIs exist.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    state = state.copyWith(currentUser: profile, isLoading: false);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(logoutUseCaseProvider).call();

    if (result.isSuccess) {
      state = const AuthState();
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to sign out.',
    );
  }
}
