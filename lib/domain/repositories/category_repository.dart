import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<ApiResult<List<Category>>> getCategories();
}
