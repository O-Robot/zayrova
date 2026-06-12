import 'package:zayrova/core/exceptions/api_exceptions.dart';
import 'package:zayrova/core/utils/api_result.dart';

Future<ApiResult<T>> guardRepositoryCall<T>(Future<T> Function() action) async {
  try {
    final data = await action();
    return ApiResult.success(data);
  } on AppException catch (error) {
    return ApiResult.error(error.message, error: error);
  } catch (error) {
    return ApiResult.error('Something went wrong. Please try again.', error: error);
  }
}
