import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<UserProfile>> login({
    required String username,
    required String password,
    int expiresInMinutes = 30,
  });

  Future<ApiResult<UserProfile>> getCurrentUser(String accessToken);

  Future<ApiResult<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
    int expiresInMinutes = 30,
  });

  /// Placeholder for future local token/session cleanup.
  Future<ApiResult<void>> logout();
}
