import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserProfile>> call({
    required String username,
    required String password,
    int expiresInMinutes = 30,
  }) {
    return _repository.login(
      username: username,
      password: password,
      expiresInMinutes: expiresInMinutes,
    );
  }
}

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserProfile>> call(String accessToken) {
    return _repository.getCurrentUser(accessToken);
  }
}

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<Map<String, dynamic>>> call({
    required String refreshToken,
    int expiresInMinutes = 30,
  }) {
    return _repository.refreshToken(
      refreshToken: refreshToken,
      expiresInMinutes: expiresInMinutes,
    );
  }
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call() {
    return _repository.logout();
  }
}
