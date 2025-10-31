class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;
  final dynamic responseData;

  ApiError({
    required this.message,
    this.statusCode,
    this.error,
    this.responseData,
  });

  factory ApiError.fromDioError(dynamic error) {
    String message = 'Uknown error';
    int? statusCode;
    dynamic responseData;

    if (error.response != null) {
      statusCode = error.response?.statusCode;
      message = error.response?.statusMessage ?? message;
      responseData = error.response?.data;
    } else if (error.error != null) {
      message = error.error.toString();
    } else {
      message = error.message ?? message;
    }

    return ApiError(
      message: message,
      statusCode: statusCode,
      error: error,
      responseData: responseData,
    );
  }

  @override
  String toString() => message;
}
