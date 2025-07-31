import 'dart:developer' as developer;
import 'package:actual/common/exceptions/custom_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 전역 에러 핸들러
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 에러 로깅 활성화 여부
  bool _loggingEnabled = true;
  
  /// 사용자 알림 활성화 여부
  bool _userNotificationEnabled = true;
  
  /// 로깅 활성화/비활성화
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }
  
  /// 사용자 알림 활성화/비활성화  
  void setUserNotificationEnabled(bool enabled) {
    _userNotificationEnabled = enabled;
  }

  /// 에러 처리 메인 메소드
  void handleError(dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    bool logError = true,
  }) {
    final customException = _convertToCustomException(error, stackTrace);
    
    // 로깅
    if (logError && _loggingEnabled) {
      _logError(customException, context: context);
    }
    
    // 사용자에게 알림
    if (showToUser && _userNotificationEnabled) {
      _showUserNotification(customException);
    }
    
    // 특별한 처리가 필요한 에러들
    _handleSpecialCases(customException);
  }

  /// Exception을 CustomException으로 변환
  CustomException _convertToCustomException(dynamic error, StackTrace? stackTrace) {
    if (error is CustomException) {
      return error;
    }
    
    if (error is DioException) {
      return _handleDioException(error, stackTrace);
    }
    
    if (error is FormatException) {
      return ValidationException(
        message: error.message,
        code: 'FORMAT_ERROR',
        field: 'unknown',
        violations: [error.message],
        stackTrace: stackTrace,
      );
    }
    
    if (error is ArgumentError) {
      return ValidationException(
        message: error.message ?? 'Invalid argument',
        code: 'ARGUMENT_ERROR',
        field: error.name ?? 'unknown',
        violations: [error.message ?? 'Invalid argument'],
        stackTrace: stackTrace,
      );
    }
    
    // 기타 모든 에러
    return CustomException(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
      details: error,
      stackTrace: stackTrace,
    ) as CustomException;
  }

  /// DioException 처리
  NetworkException _handleDioException(DioException dioError, StackTrace? stackTrace) {
    String message;
    String code;
    int? statusCode;
    
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        message = '연결 시간이 초과되었습니다';
        code = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        message = '요청 전송 시간이 초과되었습니다';
        code = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        message = '응답 수신 시간이 초과되었습니다';
        code = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        statusCode = dioError.response?.statusCode;
        message = _getStatusCodeMessage(statusCode);
        code = 'BAD_RESPONSE_$statusCode';
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다';
        code = 'REQUEST_CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = '네트워크 연결에 실패했습니다';
        code = 'CONNECTION_ERROR';
        break;
      case DioExceptionType.unknown:
      default:
        message = '알 수 없는 네트워크 오류가 발생했습니다';
        code = 'UNKNOWN_NETWORK_ERROR';
        break;
    }
    
    return NetworkException(
      message: message,
      code: code,
      statusCode: statusCode,
      endpoint: dioError.requestOptions.path,
      details: {
        'method': dioError.requestOptions.method,
        'url': dioError.requestOptions.uri.toString(),
        'headers': dioError.requestOptions.headers,
        'data': dioError.requestOptions.data,
        'response': dioError.response?.data,
      },
      stackTrace: stackTrace,
    );
  }

  /// HTTP 상태 코드별 메시지
  String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다';
      case 401:
        return '인증이 필요합니다';
      case 403:
        return '접근 권한이 없습니다';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다';
      case 408:
        return '요청 시간이 초과되었습니다';
      case 409:
        return '요청이 충돌합니다';
      case 422:
        return '처리할 수 없는 요청입니다';
      case 429:
        return '너무 많은 요청을 보냈습니다';
      case 500:
        return '서버 내부 오류가 발생했습니다';
      case 502:
        return '게이트웨이 오류가 발생했습니다';
      case 503:
        return '서비스를 사용할 수 없습니다';
      case 504:
        return '게이트웨이 시간 초과입니다';
      default:
        return '네트워크 오류가 발생했습니다 (코드: $statusCode)';
    }
  }

  /// 에러 로깅
  void _logError(CustomException error, {String? context}) {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
      'error': error.toJson(),
    };
    
    if (kDebugMode) {
      // 개발 모드에서는 자세한 로그 출력
      developer.log(
        '🚨 Error occurred: ${error.message}',
        name: 'ErrorHandler',
        error: error,
        stackTrace: error.stackTrace,
        level: 1000, // 에러 레벨
      );
      
      if (context != null) {
        developer.log('📍 Context: $context', name: 'ErrorHandler');
      }
      
      // 상세 정보 출력
      developer.log('📊 Error Details: ${logData.toString()}', name: 'ErrorHandler');
    } else {
      // 프로덕션 모드에서는 에러 로그 서비스로 전송
      _sendErrorToLoggingService(logData);
    }
  }

  /// 에러 로그 서비스로 전송 (프로덕션용)
  void _sendErrorToLoggingService(Map<String, dynamic> logData) {
    // TODO: Firebase Crashlytics, Sentry 등 에러 로깅 서비스 연동
    // 예시:
    // FirebaseCrashlytics.instance.recordError(
    //   logData['error'],
    //   logData['stackTrace'],
    //   information: [logData['context']],
    // );
  }

  /// 사용자에게 알림 표시
  void _showUserNotification(CustomException error) {
    // GetX 스낵바로 사용자 친화적인 메시지 표시
    Get.snackbar(
      _getErrorTitle(error),
      error.userFriendlyMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: _getErrorColor(error),
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  /// 에러 타입별 제목
  String _getErrorTitle(CustomException error) {
    if (error is NetworkException) {
      return '네트워크 오류';
    } else if (error is AuthException) {
      return '인증 오류';
    } else if (error is ValidationException) {
      return '입력 오류';
    } else if (error is BusinessException) {
      return '처리 오류';
    } else if (error is FileException) {
      return '파일 오류';
    } else {
      return '오류';
    }
  }

  /// 에러 타입별 색상
  Color _getErrorColor(CustomException error) {
    if (error is NetworkException) {
      return Get.theme.colorScheme.error.withOpacity(0.9);
    } else if (error is AuthException) {
      return Colors.orange.withOpacity(0.9);
    } else if (error is ValidationException) {
      return Colors.amber.withOpacity(0.9);
    } else if (error is BusinessException) {
      return Colors.blue.withOpacity(0.9);
    } else {
      return Get.theme.colorScheme.error.withOpacity(0.9);
    }
  }

  /// 특별한 처리가 필요한 경우들
  void _handleSpecialCases(CustomException error) {
    // 인증 오류 시 로그아웃 처리
    if (error is AuthException && 
        (error.errorType == AuthErrorType.tokenExpired || 
         error.errorType == AuthErrorType.tokenInvalid)) {
      _handleAuthenticationError();
    }
    
    // 네트워크 오류 시 오프라인 모드 처리
    if (error is NetworkException && error.statusCode == null) {
      _handleOfflineMode();
    }
  }

  /// 인증 오류 처리
  void _handleAuthenticationError() {
    // 현재 화면이 로그인 화면이 아닌 경우에만 로그아웃 처리
    if (Get.currentRoute != '/login') {
      // AuthController를 통한 로그아웃 처리
      try {
        Get.find<AuthController>().logout();
      } catch (e) {
        // AuthController를 찾을 수 없는 경우 직접 로그인 화면으로 이동
        Get.offAllNamed('/login');
      }
    }
  }

  /// 오프라인 모드 처리
  void _handleOfflineMode() {
    // TODO: 오프라인 모드 처리 로직
    // 예: 캐시된 데이터 사용, 오프라인 알림 표시 등
    developer.log('🔌 Offline mode detected', name: 'ErrorHandler');
  }

  /// 에러 리포팅 비활성화 (테스트용)
  void disableErrorReporting() {
    _loggingEnabled = false;
    _userNotificationEnabled = false;
  }

  /// 에러 리포팅 활성화
  void enableErrorReporting() {
    _loggingEnabled = true;
    _userNotificationEnabled = true;
  }
}

/// 전역 에러 처리 함수들
class GlobalErrorHandlers {
  /// Flutter 프레임워크 에러 처리
  static void setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandler().handleError(
        details.exception,
        stackTrace: details.stack,
        context: 'Flutter Framework Error',
      );
    };

    // PlatformDispatcher의 에러 처리 (비동기 에러)
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorHandler().handleError(
        error,
        stackTrace: stack,
        context: 'Platform Dispatcher Error',
      );
      return true;
    };
  }

  /// Zone 에러 처리 설정
  static void runAppWithErrorHandling(void Function() app) {
    runZonedGuarded(
      app,
      (error, stackTrace) {
        ErrorHandler().handleError(
          error,
          stackTrace: stackTrace,
          context: 'Zone Error',
        );
      },
    );
  }
}

/// Try-Catch 헬퍼 함수들
class SafeExecutor {
  /// 안전한 비동기 실행
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool showError = true,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      ErrorHandler().handleError(
        error,
        stackTrace: stackTrace,
        context: context,
        showToUser: showError,
      );
      return defaultValue;
    }
  }

  /// 안전한 동기 실행
  static T? safeSync<T>(
    T Function() operation, {
    String? context,
    bool showError = true,
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      ErrorHandler().handleError(
        error,
        stackTrace: stackTrace,
        context: context,
        showToUser: showError,
      );
      return defaultValue;
    }
  }
}

/// 에러 핸들링 확장 메소드
extension FutureErrorHandling<T> on Future<T> {
  /// 자동 에러 처리가 포함된 Future
  Future<T?> handleErrors({
    String? context,
    bool showError = true,
    T? defaultValue,
  }) async {
    return SafeExecutor.safeAsync(
      () => this,
      context: context,
      showError: showError,
      defaultValue: defaultValue,
    );
  }
}

// 필요한 imports
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:actual/user/controller/auth_controller.dart';