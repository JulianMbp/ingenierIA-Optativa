import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

/// HTTP client for NestJS microservice communication.
class NestJsApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  NestJsApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.nestJsBaseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_secureStorage));
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  /// Get the Dio instance for making requests
  Dio get client => _dio;

  /// Login inicial con email y password (sin obra)
  /// Este es el primer paso del flujo de autenticación
  Future<Response> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      ApiConfig.emailLoginEndpoint,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  /// Login con obra seleccionada (segundo paso)
  /// Usa el endpoint de IngenierIA que acepta obraId
  Future<Response> loginWithObra({
    required String email,
    required String password,
    required String obraId,
  }) async {
    return await _dio.post(
      ApiConfig.ingenieriaLoginEndpoint,
      data: {
        'email': email,
        'password': password,
        'obraId': obraId,
      },
    );
  }

  /// Login with email and password (legacy method - mantener compatibilidad)
  /// Optionally specify [obraId] to login with access to a specific construction project
  @Deprecated('Use loginWithEmail() or loginWithObra() instead')
  Future<Response> login({
    required String email,
    required String password,
    String? obraId,
  }) async {
    if (obraId != null && obraId.isNotEmpty) {
      return loginWithObra(email: email, password: password, obraId: obraId);
    } else {
      return loginWithEmail(email: email, password: password);
    }
  }

  /// Get current authenticated user information
  Future<Response> getCurrentUser() async {
    return await _dio.get(ApiConfig.getMeEndpoint);
  }

  /// Refresh the authentication token
  Future<Response> refreshToken(String refreshToken) async {
    return await _dio.post(
      ApiConfig.refreshTokenEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      ),
    );
  }

  /// Logout and invalidate token
  Future<Response> logout() async {
    return await _dio.post(ApiConfig.logoutEndpoint);
  }

  // ========== Obras Endpoints ==========

  /// Get all obras with pagination
  Future<Response> getObras({int page = 1, int limit = 10}) async {
    return await _dio.get(
      ApiConfig.obrasEndpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
  }

  /// Get a specific obra by ID
  Future<Response> getObraById(String obraId) async {
    return await _dio.get('${ApiConfig.obrasEndpoint}/$obraId');
  }

  /// Create a new obra
  Future<Response> createObra({
    required String nombre,
    required String direccion,
    int? administradorId,
  }) async {
    return await _dio.post(
      ApiConfig.obrasEndpoint,
      data: {
        'nombre': nombre,
        'direccion': direccion,
        if (administradorId != null) 'administradorId': administradorId,
      },
    );
  }

  /// Assign a user to an obra with a specific role
  Future<Response> assignUserToObra({
    required int userId,
    required String obraId,
    required int roleId,
  }) async {
    return await _dio.post(
      ApiConfig.asignarUsuarioObraEndpoint,
      data: {
        'userId': userId,
        'obraId': obraId,
        'roleId': roleId,
      },
    );
  }

  /// Get users assigned to a specific obra
  Future<Response> getObraUsers(String obraId) async {
    return await _dio.get('${ApiConfig.obrasEndpoint}/$obraId/usuarios');
  }
}

/// Interceptor to add authentication token to requests
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If 401 Unauthorized, try to refresh token
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _secureStorage.read(
          key: AppConstants.refreshTokenKey,
        );

        if (refreshToken != null) {
          // Attempt to refresh the token
          final dio = Dio(BaseOptions(baseUrl: ApiConfig.nestJsBaseUrl));
          final response = await dio.post(
            ApiConfig.refreshTokenEndpoint,
            options: Options(
              headers: {
                'Authorization': 'Bearer $refreshToken',
              },
            ),
          );

          if (response.statusCode == 200) {
            final newToken = response.data['token'];
            final newRefreshToken = response.data['refreshToken'];
            
            // Save both tokens
            await _secureStorage.write(
              key: AppConstants.tokenKey,
              value: newToken,
            );
            await _secureStorage.write(
              key: AppConstants.refreshTokenKey,
              value: newRefreshToken,
            );

            // Retry the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e);
      }
    }

    handler.next(err);
  }
}

/// Interceptor for logging requests and responses
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
    AppLogger.debug('Headers: ${options.headers}');
    AppLogger.debug('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    AppLogger.debug('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err.message,
    );
    AppLogger.error('Error data: ${err.response?.data}');
    handler.next(err);
  }
}

/// Interceptor for handling common errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'An unexpected error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        message = err.response?.data['message'] ?? 'Server error';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      default:
        message = err.message ?? 'Unknown error';
    }

    err = err.copyWith(message: message);
    handler.next(err);
  }
}
