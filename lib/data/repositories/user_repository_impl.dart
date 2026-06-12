import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/user_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDatasource);

  final UserRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<UserProfile>>> getUsers({int? limit, int? skip}) {
    return guardRepositoryCall(() async {
      final users = await _remoteDatasource.getUsers(
        limit: limit,
        skip: skip,
      );
      return users.map((user) => user.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<UserProfile>> getUserById(int id) {
    return guardRepositoryCall(() async {
      final user = await _remoteDatasource.getUserById(id);
      return user.toEntity();
    });
  }
}
