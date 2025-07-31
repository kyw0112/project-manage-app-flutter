import 'package:actual/common/const/data.dart';
import 'package:actual/common/error/error_handler.dart';
import 'package:actual/common/exceptions/custom_exception.dart';
import 'package:actual/common/logger/app_logger.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as getx;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Dio 클라이언트 설정 및 인터셉터 관리
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Dio 인스턴스 반환
  Dio get dio => _dio;

  /// Dio 클라이언트 초기화
  void initialize({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://$ip',
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      sendTimeout: sendTimeout ?? const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// 인터셉터 설정
  void _setupInterceptors() {
    // 1. 로깅 인터셉터 (개발 모드에서만)
    if (!kReleaseMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }

    // 2. 토큰 인터셉터
    _dio.interceptors.add(TokenInterceptor(_storage));

    // 3. 에러 처리 인터셉터
    _dio.interceptors.add(ErrorInterceptor());

    // 4. 네트워크 모니터링 인터셉터
    _dio.interceptors.add(NetworkMonitoringInterceptor());

    // 5. 캐시 인터셉터 (필요시)
    // _dio.interceptors.add(CacheInterceptor());

    // 6. 재시도 인터셉터
    _dio.interceptors.add(RetryInterceptor());
  }

  /// 헤더 업데이트
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// 베이스 URL 업데이트
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// 타임아웃 설정 업데이트
  void updateTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = sendTimeout;
    }
  }
}

/// 토큰 인터셉터 - 인증 토큰 자동 추가 및 갱신
class TokenInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;
  
  TokenInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 로그인/회원가입 요청은 토큰이 필요 없음
      if (_isAuthRequest(options.path)) {
        return handler.next(options);
      }

      // 저장된 액세스 토큰 가져오기
      final accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
      
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        logger.debug('Added access token to request: ${options.path}');
      } else {
        logger.warning('No access token available for request: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      logger.error('Error in TokenInterceptor.onRequest: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        
        if (refreshed) {
          // 토큰 갱신 성공 시 원래 요청 재시도
          final requestOptions = err.requestOptions;
          final accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
          
          requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          
          final dio = DioClient().dio;
          final response = await dio.fetch(requestOptions);
          
          return handler.resolve(response);
        } else {
          // 토큰 갱신 실패 시 로그아웃
          await _handleAuthFailure();
        }
      } catch (e) {
        logger.error('Token refresh failed: $e');
        await _handleAuthFailure();
      }
    }

    handler.next(err);
  }

  /// 인증 요청인지 확인
  bool _isAuthRequest(String path) {
    return path.contains('/auth/login') || 
           path.contains('/auth/register') ||
           path.contains('/auth/refresh');
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);
      
      if (refreshToken == null) {
        logger.warning('No refresh token available');
        return false;
      }

      final dio = Dio(); // 새로운 Dio 인스턴스 사용 (무한 루프 방지)
      final response = await dio.post(
        'http://$ip/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      if (newAccessToken != null) {
        await _storage.write(key: ACCESS_TOKEN_KEY, value: newAccessToken);
        
        if (newRefreshToken != null) {
          await _storage.write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);
        }

        logger.info('Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      logger.error('Token refresh error: $e');
      return false;
    }
  }

  /// 인증 실패 처리
  Future<void> _handleAuthFailure() async {
    try {
      // 토큰 삭제
      await _storage.delete(key: ACCESS_TOKEN_KEY);
      await _storage.delete(key: REFRESH_TOKEN_KEY);

      // AuthController를 통한 로그아웃
      final authController = getx.Get.find<AuthController>();
      await authController.logout();

      logger.info('User logged out due to auth failure');
    } catch (e) {
      logger.error('Error in auth failure handling: $e');
    }
  }
}

/// 에러 처리 인터셉터
class ErrorInterceptor extends Interceptor {
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 커스텀 예외로 변환하여 에러 핸들러에 전달
    final customException = _convertToCustomException(err);
    
    // 에러 로깅
    logger.error(
      'Network error occurred',
      tag: 'ErrorInterceptor',
      error: customException,
      stackTrace: err.stackTrace,
    );

    // 전역 에러 핸들러로 전달
    ErrorHandler().handleError(
      customException,
      context: 'Network Request: ${err.requestOptions.method} ${err.requestOptions.path}',
      showToUser: _shouldShowToUser(err),
    );

    // 원래 에러를 그대로 전달 (필요시 처리할 수 있도록)
    handler.next(err);
  }

  /// DioException을 CustomException으로 변환
  CustomException _convertToCustomException(DioException dioError) {
    return NetworkException(
      message: _getErrorMessage(dioError),
      code: _getErrorCode(dioError),
      statusCode: dioError.response?.statusCode,
      endpoint: dioError.requestOptions.path,
      details: {
        'method': dioError.requestOptions.method,
        'url': dioError.requestOptions.uri.toString(),
        'response': dioError.response?.data,
      },
      stackTrace: dioError.stackTrace,
    );
  }

  /// 에러 메시지 생성
  String _getErrorMessage(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return '서버 연결 시간이 초과되었습니다';
      case DioExceptionType.sendTimeout:
        return '요청 전송 시간이 초과되었습니다';
      case DioExceptionType.receiveTimeout:
        return '응답 수신 시간이 초과되었습니다';
      case DioExceptionType.badResponse:
        return dioError.response?.data?['message'] ?? 
               '서버에서 오류가 발생했습니다 (${dioError.response?.statusCode})';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다';
      case DioExceptionType.connectionError:
        return '네트워크 연결에 실패했습니다';
      case DioExceptionType.unknown:
      default:
        return '알 수 없는 네트워크 오류가 발생했습니다';
    }
  }

  /// 에러 코드 생성
  String _getErrorCode(DioException dioError) {
    if (dioError.response?.statusCode != null) {
      return 'HTTP_${dioError.response!.statusCode}';
    }
    
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.cancel:
        return 'REQUEST_CANCELLED';
      case DioExceptionType.connectionError:
        return 'CONNECTION_ERROR';
      case DioExceptionType.unknown:
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  /// 사용자에게 에러를 표시할지 결정
  bool _shouldShowToUser(DioException err) {
    // 요청 취소는 사용자에게 표시하지 않음
    if (err.type == DioExceptionType.cancel) {
      return false;
    }
    
    // 401은 토큰 인터셉터에서 처리하므로 표시하지 않음
    if (err.response?.statusCode == 401) {
      return false;
    }
    
    return true;
  }
}

/// 네트워크 모니터링 인터셉터
class NetworkMonitoringInterceptor extends Interceptor {
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now();
    options.extra['startTime'] = startTime;

    logger.networkRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers,
      data: options.data,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final endTime = DateTime.now();
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null ? endTime.difference(startTime) : null;

    logger.networkResponse(
      statusCode: response.statusCode ?? 0,
      url: response.requestOptions.uri.toString(),
      data: response.data,
      duration: duration?.inMilliseconds,
    );

    // 성능 로깅
    if (duration != null && duration.inMilliseconds > 1000) {
      logger.warning(
        'Slow network request: ${response.requestOptions.method} ${response.requestOptions.uri} took ${duration.inMilliseconds}ms'
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final endTime = DateTime.now();
    final startTime = err.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null ? endTime.difference(startTime) : null;

    logger.error(
      'Network request failed: ${err.requestOptions.method} ${err.requestOptions.uri}',
      tag: 'NetworkMonitoring',
      error: err,
    );

    handler.next(err);
  }
}

/// 재시도 인터셉터
class RetryInterceptor extends Interceptor {
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    
    // 재시도 가능한 에러인지 확인
    if (_shouldRetry(err)) {
      final retryCount = requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        requestOptions.extra['retryCount'] = retryCount + 1;
        
        logger.warning(
          'Retrying request (${retryCount + 1}/$maxRetries): ${requestOptions.method} ${requestOptions.path}',
          tag: 'RetryInterceptor',
        );

        // 재시도 전 지연
        await Future.delayed(retryDelay * (retryCount + 1));
        
        try {
          final dio = DioClient().dio;
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // 재시도도 실패한 경우 원래 에러를 전달
          logger.error(
            'Retry failed: ${requestOptions.method} ${requestOptions.path}',
            tag: 'RetryInterceptor',
            error: e,
          );
        }
      } else {
        logger.error(
          'Max retries exceeded: ${requestOptions.method} ${requestOptions.path}',
          tag: 'RetryInterceptor',
        );
      }
    }

    handler.next(err);
  }

  /// 재시도 가능한 에러인지 확인
  bool _shouldRetry(DioException err) {
    // 네트워크 연결 오류나 타임아웃만 재시도
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            [500, 502, 503, 504].contains(err.response!.statusCode));
  }
}

/// 캐시 인터셉터 (선택적)
class CacheInterceptor extends Interceptor {
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;

  final Map<String, Response> _cache = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);
  final Map<String, DateTime> _cacheTime = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // GET 요청만 캐시
    if (options.method.toUpperCase() == 'GET' && _shouldCache(options.path)) {
      final cacheKey = _getCacheKey(options);
      final cachedResponse = _cache[cacheKey];
      final cacheTime = _cacheTime[cacheKey];
      
      if (cachedResponse != null && cacheTime != null) {
        final isExpired = DateTime.now().difference(cacheTime) > _cacheExpiry;
        
        if (!isExpired) {
          logger.debug('Returning cached response for: ${options.path}');
          return handler.resolve(cachedResponse);
        } else {
          // 캐시 만료된 경우 제거
          _cache.remove(cacheKey);
          _cacheTime.remove(cacheKey);
        }
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    
    // GET 요청 응답을 캐시
    if (options.method.toUpperCase() == 'GET' && 
        _shouldCache(options.path) && 
        response.statusCode == 200) {
      final cacheKey = _getCacheKey(options);
      _cache[cacheKey] = response;
      _cacheTime[cacheKey] = DateTime.now();
      
      logger.debug('Cached response for: ${options.path}');
    }

    handler.next(response);
  }

  /// 캐시할지 결정
  bool _shouldCache(String path) {
    // 사용자 정보, 프로젝트 목록 등 자주 변경되지 않는 데이터만 캐시
    return path.contains('/projects') || 
           path.contains('/users') ||
           path.contains('/settings');
  }

  /// 캐시 키 생성
  String _getCacheKey(RequestOptions options) {
    return '${options.method}_${options.uri.toString()}';
  }

  /// 캐시 클리어
  void clearCache() {
    _cache.clear();
    _cacheTime.clear();
    logger.info('Cache cleared');
  }
}

