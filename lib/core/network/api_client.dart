import 'package:acceptance_app/data/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/api_error.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: envLogin,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _createLogInterceptor(),
      _createErrorInterceptor(),
    ]);

    return dio;
  }

  static Interceptor _createLogInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        if (kDebugMode) {
          print('API Log: $object');
        }
      },
    );
  }

  static Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiError(message: 'Tiempo de espera agotado'),
            ),
          );
          return;
        }

        if (error.type == DioExceptionType.badResponse) {
          final statusCode = error.response?.statusCode;
          final String message =
              error.response?.data['errors']?[0]?['message'] ?? 'Unknown error';

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiError(
                message: message,
                statusCode: statusCode,
              ),
            ),
          );
          return;
        }

        handler.next(error);
      },
    );
  }
}
