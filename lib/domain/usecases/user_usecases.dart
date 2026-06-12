import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/domain/repositories/user_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final UserRepository _repository;

  Future<ApiResult<List<UserProfile>>> call({int? limit, int? skip}) {
    return _repository.getUsers(limit: limit, skip: skip);
  }
}

class GetUserByIdUseCase {
  const GetUserByIdUseCase(this._repository);

  final UserRepository _repository;

  Future<ApiResult<UserProfile>> call(int id) {
    return _repository.getUserById(id);
  }
}
