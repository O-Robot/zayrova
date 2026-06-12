import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/category_entity.dart';
import 'package:zayrova/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<ApiResult<List<Category>>> call() {
    return _repository.getCategories();
  }
}
