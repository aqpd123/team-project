import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
    this.onTokenExpired,
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
  VoidCallback? onTokenExpired;

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

    // 영어 오류 메시지를 한국어로 변환
    message = _translateErrorMessage(message);

    // 토큰 만료 시 자동 로그아웃 처리
    if (status == 401 && (message.contains('토큰') || message.contains('만료') || message.contains('인증'))) {
      onTokenExpired?.call();
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
    }

    return ApiException(message, statusCode: status, details: details);
  }

  String _translateErrorMessage(String message) {
    // Marshmallow validation 오류 메시지 한국어 변환
    final translations = {
      'email': '이메일',
      'password': '비밀번호',
      'username': '사용자명',
      'Missing data for required field.': '필수 항목이 누락되었습니다.',
      'Not a valid email address.': '올바른 이메일 주소를 입력해주세요.',
      'Length must be between': '길이는',
      'and': '과',
      'characters long.': '자 사이여야 합니다.',
      'Shorter than minimum length': '최소 길이보다 짧습니다.',
      'Longer than maximum length': '최대 길이보다 깁니다.',
      'Invalid value.': '유효하지 않은 값입니다.',
      'Field may not be null.': '필수 항목입니다.',
      'Field may not be blank.': '비어있을 수 없습니다.',
    };

    String translated = message;

    // 이메일 관련 오류
    if (translated.toLowerCase().contains('email')) {
      if (translated.toLowerCase().contains('required') || 
          translated.toLowerCase().contains('missing')) {
        translated = '이메일을 입력해주세요.';
      } else if (translated.toLowerCase().contains('valid') || 
                 translated.toLowerCase().contains('invalid')) {
        translated = '올바른 이메일 주소를 입력해주세요.';
      }
    }

    // 비밀번호 관련 오류
    if (translated.toLowerCase().contains('password')) {
      if (translated.toLowerCase().contains('required') || 
          translated.toLowerCase().contains('missing')) {
        translated = '비밀번호를 입력해주세요.';
      } else if (translated.toLowerCase().contains('length') || 
                 translated.toLowerCase().contains('shorter')) {
        if (translated.contains('6')) {
          translated = '비밀번호는 최소 6자 이상이어야 합니다.';
        } else {
          translated = '비밀번호 길이가 올바르지 않습니다.';
        }
      }
    }

    // 사용자명 관련 오류
    if (translated.toLowerCase().contains('username')) {
      if (translated.toLowerCase().contains('required') || 
          translated.toLowerCase().contains('missing')) {
        translated = '사용자명을 입력해주세요.';
      } else if (translated.toLowerCase().contains('length')) {
        translated = '사용자명은 2자 이상 50자 이하여야 합니다.';
      }
    }

    // 일반적인 validation 오류 메시지 변환
    for (final entry in translations.entries) {
      if (translated.toLowerCase().contains(entry.key.toLowerCase())) {
        // 이미 특정 오류로 변환된 경우 스킵
        if (!translated.contains('이메일') && 
            !translated.contains('비밀번호') && 
            !translated.contains('사용자명')) {
          translated = translated.replaceAll(entry.key, entry.value);
        }
      }
    }

    return translated;
  }
}


