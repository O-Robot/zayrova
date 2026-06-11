enum ApiResultStatus { loading, success, error }

class ApiResult<T> {
  const ApiResult._({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  final ApiResultStatus status;
  final T? data;
  final String? message;
  final Object? error;

  const ApiResult.loading() : this._(status: ApiResultStatus.loading);

  const ApiResult.success(T data)
    : this._(status: ApiResultStatus.success, data: data);

  const ApiResult.error(String message, {Object? error})
    : this._(
        status: ApiResultStatus.error,
        message: message,
        error: error,
      );

  bool get isLoading => status == ApiResultStatus.loading;

  bool get isSuccess => status == ApiResultStatus.success;

  bool get isError => status == ApiResultStatus.error;
}
