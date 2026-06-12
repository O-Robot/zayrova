import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/user_profile_model.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfileModel> login({
    required String username,
    required String password,
    int expiresInMinutes = 30,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authLogin,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': expiresInMinutes,
      },
    );

    return UserProfileModel.fromJson(_mapFromResponse(response));
  }

  Future<UserProfileModel> getCurrentUser(String accessToken) async {
    final response = await _apiClient.get(
      ApiConstants.authMe,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return UserProfileModel.fromJson(_mapFromResponse(response));
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
    int expiresInMinutes = 30,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authRefresh,
      body: {
        'refreshToken': refreshToken,
        'expiresInMins': expiresInMinutes,
      },
    );

    return _mapFromResponse(response);
  }

  Map<String, dynamic> _mapFromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    return const {};
  }
}
