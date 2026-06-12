import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/category_model.dart';

class CategoryRemoteDatasource {
  const CategoryRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.productCategories);
    final source = response is Map<String, dynamic>
        ? response['categories']
        : response;

    if (source is! List) {
      return const [];
    }

    return source.map(CategoryModel.fromJson).toList();
  }
}
