import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/user_profile_model.dart';

class UserRemoteDatasource {
  const UserRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<UserProfileModel>> getUsers({
    int? limit,
    int? skip,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.users,
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (skip != null) 'skip': skip,
      },
    );
    final source = response is Map<String, dynamic>
        ? response['users']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(UserProfileModel.fromJson)
        .toList();
  }

  Future<UserProfileModel> getUserById(int id) async {
    final response = await _apiClient.get(ApiConstants.userById(id));

    if (response is Map<String, dynamic>) {
      return UserProfileModel.fromJson(response);
    }

    return const UserProfileModel(id: '');
  }
}
