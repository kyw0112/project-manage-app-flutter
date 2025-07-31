import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 모바일/데스크톱용 앱 로거 클래스 (파일 로깅 지원)
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  static AppLogger get instance => _instance;

  /// 로그 레벨
  LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  
  /// 파일 로깅 활성화 여부
  bool _fileLoggingEnabled = false;
  
  /// 로그 파일 경로
  String? _logFilePath;
  
  /// 최대 로그 파일 크기 (MB)
  static const int _maxLogFileSize = 10;
  
  /// 최대 로그 파일 개수
  static const int _maxLogFiles = 3;

  /// 로그 레벨 설정
  void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// 파일 로깅 활성화
  Future<void> enableFileLogging() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      _logFilePath = '${logDir.path}/app_${DateTime.now().millisecondsSinceEpoch}.log';
      _fileLoggingEnabled = true;
      
      info('File logging enabled: $_logFilePath');
    } catch (e) {
      error('Failed to enable file logging: $e');
    }
  }

  /// 파일 로깅 비활성화
  void disableFileLogging() {
    _fileLoggingEnabled = false;
    _logFilePath = null;
    info('File logging disabled');
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

    // 콘솔 출력
    _logToConsole(formattedMessage, level, error, stackTrace);
    
    // 파일 출력 (활성화된 경우)
    if (_fileLoggingEnabled && _logFilePath != null) {
      _logToFile(formattedMessage, error, stackTrace);
    }
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
      // 프로덕션에서는 print 사용 (Firebase Crashlytics에서 수집 가능)
      print(message);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// 파일 로그 출력
  void _logToFile(String message, dynamic error, StackTrace? stackTrace) {
    if (_logFilePath == null) return;

    try {
      final file = File(_logFilePath!);
      final logEntry = StringBuffer(message);
      
      if (error != null) {
        logEntry.writeln('\nError: $error');
      }
      
      if (stackTrace != null) {
        logEntry.writeln('StackTrace: $stackTrace');
      }
      
      logEntry.writeln('---');

      // 파일 크기 체크 및 로테이션
      if (file.existsSync()) {
        final fileSize = file.lengthSync();
        if (fileSize > _maxLogFileSize * 1024 * 1024) {
          _rotateLogFiles();
        }
      }

      file.writeAsStringSync('${logEntry.toString()}\n', mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write log to file: $e', name: 'AppLogger');
    }
  }

  /// 로그 파일 로테이션
  void _rotateLogFiles() {
    try {
      final currentFile = File(_logFilePath!);
      if (!currentFile.existsSync()) return;

      final directory = currentFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/app_$timestamp.log';
      
      currentFile.renameSync(newPath);
      
      // 오래된 로그 파일 삭제
      _cleanupOldLogFiles(directory);
    } catch (e) {
      developer.log('Failed to rotate log files: $e', name: 'AppLogger');
    }
  }

  /// 오래된 로그 파일 정리
  void _cleanupOldLogFiles(Directory logDirectory) {
    try {
      final logFiles = logDirectory
          .listSync()
          .where((file) => file.path.endsWith('.log'))
          .map((file) => File(file.path))
          .toList();

      if (logFiles.length <= _maxLogFiles) return;

      // 수정 시간으로 정렬
      logFiles.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      // 오래된 파일 삭제
      final filesToDelete = logFiles.take(logFiles.length - _maxLogFiles);
      for (final file in filesToDelete) {
        file.deleteSync();
      }
    } catch (e) {
      developer.log('Failed to cleanup old log files: $e', name: 'AppLogger');
    }
  }

  /// 로그 레벨 확인
  bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// 색상 추가
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

  /// 로그 통계 조회
  Future<LogStats> getLogStats() async {
    if (!_fileLoggingEnabled || _logFilePath == null) {
      return LogStats.empty();
    }

    try {
      final logDir = File(_logFilePath!).parent;
      final logFiles = logDir
          .listSync()
          .where((file) => file.path.endsWith('.log'))
          .map((file) => File(file.path))
          .toList();

      int totalLines = 0;
      int totalSize = 0;
      
      for (final file in logFiles) {
        if (file.existsSync()) {
          totalSize += file.lengthSync();
          totalLines += file.readAsLinesSync().length;
        }
      }

      return LogStats(
        fileCount: logFiles.length,
        totalLines: totalLines,
        totalSizeBytes: totalSize,
        oldestLogDate: logFiles.isNotEmpty 
            ? logFiles.map((f) => f.lastModifiedSync()).reduce((a, b) => a.isBefore(b) ? a : b)
            : null,
        newestLogDate: logFiles.isNotEmpty 
            ? logFiles.map((f) => f.lastModifiedSync()).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      );
    } catch (e) {
      error('Failed to get log stats: $e');
      return LogStats.empty();
    }
  }

  /// 로그 파일 내보내기
  Future<List<String>?> exportLogs() async {
    if (!_fileLoggingEnabled) return null;

    try {
      final logDir = File(_logFilePath!).parent;
      final logFiles = logDir
          .listSync()
          .where((file) => file.path.endsWith('.log'))
          .map((file) => file.path)
          .toList();

      return logFiles;
    } catch (e) {
      error('Failed to export logs: $e');
      return null;
    }
  }

  /// 모든 로그 파일 삭제
  Future<void> clearAllLogs() async {
    if (!_fileLoggingEnabled || _logFilePath == null) return;

    try {
      final logDir = File(_logFilePath!).parent;
      final logFiles = logDir
          .listSync()
          .where((file) => file.path.endsWith('.log'))
          .toList();

      for (final file in logFiles) {
        await file.delete();
      }
      
      info('All log files cleared');
    } catch (e) {
      error('Failed to clear logs: $e');
    }
  }
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