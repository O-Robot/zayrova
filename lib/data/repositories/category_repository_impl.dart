import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/category_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/category_entity.dart';
import 'package:zayrova/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remoteDatasource);

  final CategoryRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<Category>>> getCategories() {
    return guardRepositoryCall(() async {
      final categories = await _remoteDatasource.getCategories();
      return categories.map((category) => category.toEntity()).toList();
    });
  }
}
