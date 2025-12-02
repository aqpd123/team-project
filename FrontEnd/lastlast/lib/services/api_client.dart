import 'dart:convert';

import 'package:dio/dio.dart';

const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  // 에뮬레이터: http://10.0.2.2:5000
  // 실제 기기 (WiFi 디버깅): PC의 IP 주소 사용 (예: http://192.168.0.7:5000)
  defaultValue: 'http://192.168.0.7:5000',
);

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({
    String? baseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? defaultApiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Content-Type': 'application/json; charset=utf-8',
                },
              ),
            );

  final Dio _dio;
  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestMap(
      () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: _optionsWithAuth(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _requestMap(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _optionsWithAuth(headers: headers),
      ),
    );
  }

  Future<void> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await _request(
      () => _dio.delete<void>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _optionsWithAuth(headers: headers),
      ),
    );
  }

  Options _optionsWithAuth({Map<String, String>? headers}) {
    final mergedHeaders = <String, String>{};
    if (headers != null) {
      mergedHeaders.addAll(headers);
    }
    if (_token != null && _token!.isNotEmpty) {
      mergedHeaders['Authorization'] = 'Bearer $_token';
    }
    return Options(headers: mergedHeaders);
  }

  Future<Map<String, dynamic>> _requestMap(
    Future<Response<Map<String, dynamic>>> Function() action,
  ) async {
    final data = await _request(action);
    return data ?? <String, dynamic>{};
  }

  Future<T?> _request<T>(Future<Response<T>> Function() action) async {
    try {
      final response = await action();
      return response.data;
    } on DioException catch (err) {
      throw _toApiException(err);
    } catch (_) {
      throw const ApiException('네트워크 오류가 발생했습니다.');
    }
  }

  ApiException _toApiException(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    String message = '서버와 통신 중 오류가 발생했습니다.';
    Map<String, dynamic>? details;

    if (data is Map<String, dynamic>) {
      message = (data['error'] ?? data['message'] ?? message).toString();
      details = data;
    } else if (data is String && data.isNotEmpty) {
      message = data;
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map<String, dynamic>) {
          details = parsed;
          message = (parsed['error'] ?? parsed['message'] ?? message).toString();
        }
      } catch (_) {
        // ignore decode failures
      }
    } else if (err.message != null) {
      message = err.message!;
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
    }

    return ApiException(message, statusCode: status, details: details);
  }
}


