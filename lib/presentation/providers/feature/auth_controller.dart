import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/utils/local_storage.dart';
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
  static const String _profileStorageKey = 'auth_current_user';
  static const String _tokenStorageKey = 'auth_token_data';

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final profileData = await LocalStorage.get(_profileStorageKey, Map);
    final tokenData = await LocalStorage.get(_tokenStorageKey, Map);
    final profile = profileData is Map ? _profileFromMap(profileData) : null;

    state = state.copyWith(
      currentUser: profile,
      tokenData: tokenData is Map ? Map<String, dynamic>.from(tokenData) : null,
      isLoading: false,
      clearUser: profile == null,
      clearTokenData: tokenData is! Map,
    );
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
      await _persistProfile(result.data!);
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
      await _persistProfile(result.data!);
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
      await LocalStorage.set(_tokenStorageKey, result.data!);
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
    await _persistProfile(profile);

    state = state.copyWith(currentUser: profile, isLoading: false);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(logoutUseCaseProvider).call();

    if (result.isSuccess) {
      await LocalStorage.delete(_profileStorageKey);
      await LocalStorage.delete(_tokenStorageKey);
      state = const AuthState();
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to sign out.',
    );
  }

  Future<void> _persistProfile(UserProfile profile) {
    return LocalStorage.set(_profileStorageKey, _profileToMap(profile));
  }

  Map<String, dynamic> _profileToMap(UserProfile profile) {
    return {
      'id': profile.id,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'fullName': profile.fullName,
      'email': profile.email,
      'phoneNumber': profile.phoneNumber,
      'avatarUrl': profile.avatarUrl,
      'dateOfBirth': profile.dateOfBirth?.toIso8601String(),
      'gender': profile.gender,
      'isEmailVerified': profile.isEmailVerified,
      'isPhoneVerified': profile.isPhoneVerified,
    };
  }

  UserProfile _profileFromMap(Map<dynamic, dynamic> data) {
    final dateOfBirth = _stringValue(data['dateOfBirth']);

    return UserProfile(
      id: _stringValue(data['id']) ?? 'local-user',
      firstName: _stringValue(data['firstName']),
      lastName: _stringValue(data['lastName']),
      fullName: _stringValue(data['fullName']),
      email: _stringValue(data['email']),
      phoneNumber: _stringValue(data['phoneNumber']),
      avatarUrl: _stringValue(data['avatarUrl']),
      dateOfBirth: dateOfBirth == null ? null : DateTime.tryParse(dateOfBirth),
      gender: _stringValue(data['gender']),
      isEmailVerified: data['isEmailVerified'] == true,
      isPhoneVerified: data['isPhoneVerified'] == true,
    );
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
