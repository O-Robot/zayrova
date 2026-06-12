import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';

abstract class UserRepository {
  Future<ApiResult<List<UserProfile>>> getUsers({int? limit, int? skip});

  Future<ApiResult<UserProfile>> getUserById(int id);
}
