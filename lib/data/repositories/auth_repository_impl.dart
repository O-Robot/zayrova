import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/auth_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<UserProfile>> login({
    required String username,
    required String password,
    int expiresInMinutes = 30,
  }) {
    return guardRepositoryCall(() async {
      final user = await _remoteDatasource.login(
        username: username,
        password: password,
        expiresInMinutes: expiresInMinutes,
      );
      return user.toEntity();
    });
  }

  @override
  Future<ApiResult<UserProfile>> getCurrentUser(String accessToken) {
    return guardRepositoryCall(() async {
      final user = await _remoteDatasource.getCurrentUser(accessToken);
      return user.toEntity();
    });
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
    int expiresInMinutes = 30,
  }) {
    return guardRepositoryCall(() {
      return _remoteDatasource.refreshToken(
        refreshToken: refreshToken,
        expiresInMinutes: expiresInMinutes,
      );
    });
  }

  @override
  Future<ApiResult<void>> logout() {
    // Local/session cleanup will live here when token persistence is added.
    return guardRepositoryCall(() async {});
  }
}
