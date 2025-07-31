import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 웹용 앱 로거 클래스 (파일 로깅 미지원)
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static AppLogger get instance => _instance;

  /// 로그 레벨
  LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// 로그 레벨 설정
  void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// 파일 로깅 활성화 (웹에서는 지원되지 않음)
  Future<void> enableFileLogging() async {
    if (kDebugMode) {
      print('AppLogger: File logging is not supported on web platform');
    }
  }

  /// 파일 로깅 비활성화
  void disableFileLogging() {
    // 웹에서는 아무것도 하지 않음
  }

  /// Debug 로그
  void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Info 로그
  void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Warning 로그
  void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Error 로그
  void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Critical 로그
  void critical(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 네트워크 요청 로그
  void networkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    String? tag,
  }) {
    if (_shouldLog(LogLevel.debug)) {
      final logMessage = _formatNetworkRequest(method, url, headers, data);
      _log(LogLevel.debug, logMessage, tag: tag ?? 'NETWORK');
    }
  }

  /// 네트워크 응답 로그
  void networkResponse({
    required int statusCode,
    required String url,
    dynamic data,
    int? duration,
    String? tag,
  }) {
    if (_shouldLog(LogLevel.debug)) {
      final logMessage = _formatNetworkResponse(statusCode, url, data, duration);
      _log(LogLevel.debug, logMessage, tag: tag ?? 'NETWORK');
    }
  }

  /// 내부 로그 처리
  void _log(LogLevel level, String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    final tagString = tag != null ? '[$tag] ' : '';
    final formattedMessage = '[$timestamp] $levelName: $tagString$message';

    // 웹에서는 브라우저 콘솔에만 출력
    _logToConsole(formattedMessage, level, error, stackTrace);
  }

  /// 콘솔 로그 출력
  void _logToConsole(String message, LogLevel level, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      // 개발 모드에서는 색상이 있는 로그 출력
      final coloredMessage = _addColor(message, level);
      developer.log(coloredMessage, name: 'AppLogger');
      
      if (error != null) {
        developer.log('Error: $error', name: 'AppLogger');
      }
      if (stackTrace != null) {
        developer.log('StackTrace: $stackTrace', name: 'AppLogger');
      }
    } else {
      // 프로덕션에서는 기본 console.log 사용
      print(message);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// 로그 레벨 확인
  bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// 색상 추가 (웹 콘솔용)
  String _addColor(String message, LogLevel level) {
    const colors = {
      LogLevel.debug: '\x1B[37m',    // 흰색
      LogLevel.info: '\x1B[36m',     // 청색
      LogLevel.warning: '\x1B[33m',  // 노란색
      LogLevel.error: '\x1B[31m',    // 빨간색
      LogLevel.critical: '\x1B[35m', // 자주색
    };
    const reset = '\x1B[0m';
    
    final color = colors[level] ?? '';
    return '$color$message$reset';
  }

  /// 네트워크 요청 포맷팅
  String _formatNetworkRequest(String method, String url, Map<String, dynamic>? headers, dynamic data) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 HTTP Request:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $url');
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('  Headers: ${_sanitizeHeaders(headers)}');
    }
    
    if (data != null) {
      buffer.writeln('  Body: ${_sanitizeData(data)}');
    }
    
    return buffer.toString().trim();
  }

  /// 네트워크 응답 포맷팅
  String _formatNetworkResponse(int statusCode, String url, dynamic data, int? duration) {
    final buffer = StringBuffer();
    buffer.writeln('📡 HTTP Response:');
    buffer.writeln('  Status: $statusCode');
    buffer.writeln('  URL: $url');
    
    if (duration != null) {
      buffer.writeln('  Duration: ${duration}ms');
    }
    
    if (data != null) {
      final sanitizedData = _sanitizeData(data);
      if (sanitizedData.length > 1000) {
        buffer.writeln('  Body: ${sanitizedData.substring(0, 1000)}...[truncated]');
      } else {
        buffer.writeln('  Body: $sanitizedData');
      }
    }
    
    return buffer.toString().trim();
  }

  /// 헤더 정보 정리 (민감한 정보 제거)
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    
    // 민감한 헤더 필드 마스킹
    final sensitiveKeys = ['authorization', 'cookie', 'x-api-key', 'x-auth-token'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key.toLowerCase()) || 
          sanitized.containsKey(key.toUpperCase()) ||
          sanitized.containsKey(key)) {
        sanitized[key] = '***';
      }
    }
    
    return sanitized;
  }

  /// 데이터 정리 (민감한 정보 제거)
  String _sanitizeData(dynamic data) {
    if (data == null) return 'null';
    
    String dataString = data.toString();
    
    // 패스워드 관련 필드 마스킹
    final sensitivePatterns = [
      RegExp(r'"password"\s*:\s*"[^"]*"', caseSensitive: false),
      RegExp(r'"token"\s*:\s*"[^"]*"', caseSensitive: false),
      RegExp(r'"secret"\s*:\s*"[^"]*"', caseSensitive: false),
    ];
    
    for (final pattern in sensitivePatterns) {
      dataString = dataString.replaceAll(pattern, '"***":"***"');
    }
    
    return dataString;
  }

  // 웹에서는 파일 관련 기능들이 모두 빈 구현
  Future<LogStats> getLogStats() async => LogStats.empty();
  Future<List<String>?> exportLogs() async => null;
  Future<void> clearAllLogs() async {}
}

/// 로그 레벨 열거형
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// 로그 통계 클래스
class LogStats {
  final int fileCount;
  final int totalLines;
  final int totalSizeBytes;
  final DateTime? oldestLogDate;
  final DateTime? newestLogDate;

  const LogStats({
    required this.fileCount,
    required this.totalLines,
    required this.totalSizeBytes,
    this.oldestLogDate,
    this.newestLogDate,
  });

  factory LogStats.empty() => const LogStats(
    fileCount: 0,
    totalLines: 0,  
    totalSizeBytes: 0,
  );
}