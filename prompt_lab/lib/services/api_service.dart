import 'package:dio/dio.dart';

import '../models/user.dart';
import '../models/user_profile.dart';

/// Помилка, яку ApiService віддає екранам замість DioException.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Усі запити до тестового сервера dummyjson.com.
class ApiService {
  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://dummyjson.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    // додаю токен до кожного запиту, якщо користувач уже увійшов
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  String? _token;

  bool get isLoggedIn => _token != null;

  /// Вхід. Тестовий сервер приймає логін у полі username.
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': email, 'password': password, 'expiresInMins': 30},
      );
      final user = User.fromJson(response.data as Map<String, dynamic>);
      _token = user.accessToken;
      return user;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// Список користувачів.
  Future<List<User>> fetchUsers({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/users',
        queryParameters: {'limit': limit},
      );
      final list = (response.data['users'] as List).cast<Map<String, dynamic>>();
      return list.map(User.fromJson).toList();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// Профіль користувача за id.
  Future<UserProfile> fetchUserProfile(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  void logout() => _token = null;

  /// Переводжу DioException у зрозуміле повідомлення.
  ApiException _toApiException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Сервер не відповідає, спробуйте пізніше');
      case DioExceptionType.connectionError:
        return const ApiException('Немає з\'єднання з інтернетом');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map && data['message'] is String
            ? data['message'] as String
            : 'Помилка сервера';
        return ApiException('$message ($code)', statusCode: code);
      default:
        return ApiException('Невідома помилка: ${e.message}');
    }
  }
}
