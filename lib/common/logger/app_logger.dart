import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 앱 로거 클래스
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
    required String method,
    required String url,
    required int statusCode,
    Map<String, dynamic>? headers,
    dynamic data,
    Duration? duration,
    String? tag,
  }) {
    if (_shouldLog(LogLevel.debug)) {
      final logMessage = _formatNetworkResponse(method, url, statusCode, headers, data, duration);
      _log(LogLevel.debug, logMessage, tag: tag ?? 'NETWORK');
    }
  }

  /// 사용자 액션 로그
  void userAction(String action, {Map<String, dynamic>? parameters, String? tag}) {
    if (_shouldLog(LogLevel.info)) {
      final logMessage = _formatUserAction(action, parameters);
      _log(LogLevel.info, logMessage, tag: tag ?? 'USER_ACTION');
    }
  }

  /// 성능 측정 로그
  void performance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
    String? tag,
  }) {
    if (_shouldLog(LogLevel.info)) {
      final logMessage = _formatPerformance(operation, duration, metadata);
      _log(LogLevel.info, logMessage, tag: tag ?? 'PERFORMANCE');
    }
  }

  /// 앱 생명주기 로그
  void lifecycle(String event, {Map<String, dynamic>? data, String? tag}) {
    if (_shouldLog(LogLevel.info)) {
      final logMessage = _formatLifecycle(event, data);
      _log(LogLevel.info, logMessage, tag: tag ?? 'LIFECYCLE');
    }
  }

  /// 메인 로그 메소드
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now();
    final formattedMessage = _formatLogMessage(level, message, tag, timestamp);

    // 콘솔 출력
    _logToConsole(level, formattedMessage, error, stackTrace);

    // 파일 출력
    if (_fileLoggingEnabled && _logFilePath != null) {
      _logToFile(formattedMessage, error, stackTrace);
    }
  }

  /// 로그 출력 여부 결정
  bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// 로그 메시지 포맷팅
  String _formatLogMessage(LogLevel level, String message, String? tag, DateTime timestamp) {
    final timeStr = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(8);
    final tagStr = tag != null ? '[$tag]' : '';
    
    return '$timeStr $levelStr $tagStr $message';
  }

  /// 콘솔 로그 출력
  void _logToConsole(LogLevel level, String message, dynamic error, StackTrace? stackTrace) {
    final emoji = _getLevelEmoji(level);
    final coloredMessage = _colorizeMessage(level, '$emoji $message');

    if (kDebugMode) {
      developer.log(
        coloredMessage,
        name: 'AppLogger',
        level: _getDeveloperLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      // 프로덕션에서는 print 사용 (Firebase Crashlytics에서 수집 가능)
      print(coloredMessage);
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
  String _formatNetworkResponse(
    String method,
    String url,
    int statusCode,
    Map<String, dynamic>? headers,
    dynamic data,
    Duration? duration,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('📡 HTTP Response:');
    buffer.writeln('  Method: $method');
    buffer.writeln('  URL: $url');
    buffer.writeln('  Status: $statusCode');
    
    if (duration != null) {
      buffer.writeln('  Duration: ${duration.inMilliseconds}ms');
    }
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('  Headers: ${_sanitizeHeaders(headers)}');
    }
    
    if (data != null) {
      final dataStr = _sanitizeData(data);
      if (dataStr.length > 1000) {
        buffer.writeln('  Body: ${dataStr.substring(0, 1000)}... (truncated)');
      } else {
        buffer.writeln('  Body: $dataStr');
      }
    }
    
    return buffer.toString().trim();
  }

  /// 사용자 액션 포맷팅
  String _formatUserAction(String action, Map<String, dynamic>? parameters) {
    final buffer = StringBuffer();
    buffer.writeln('👤 User Action: $action');
    
    if (parameters != null && parameters.isNotEmpty) {
      buffer.writeln('  Parameters: ${_sanitizeData(parameters)}');
    }
    
    return buffer.toString().trim();
  }

  /// 성능 측정 포맷팅
  String _formatPerformance(String operation, Duration duration, Map<String, dynamic>? metadata) {
    final buffer = StringBuffer();
    buffer.writeln('⚡ Performance: $operation');
    buffer.writeln('  Duration: ${duration.inMilliseconds}ms');
    
    if (metadata != null && metadata.isNotEmpty) {
      buffer.writeln('  Metadata: $metadata');
    }
    
    return buffer.toString().trim();
  }

  /// 앱 생명주기 포맷팅
  String _formatLifecycle(String event, Map<String, dynamic>? data) {
    final buffer = StringBuffer();
    buffer.writeln('🔄 Lifecycle: $event');
    
    if (data != null && data.isNotEmpty) {
      buffer.writeln('  Data: $data');
    }
    
    return buffer.toString().trim();
  }

  /// 민감한 헤더 정보 제거
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    
    // 민감한 헤더 마스킹
    const sensitiveHeaders = ['authorization', 'cookie', 'x-api-key', 'x-auth-token'];
    
    for (final key in sanitized.keys.toList()) {
      if (sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '***';
      }
    }
    
    return sanitized;
  }

  /// 민감한 데이터 제거
  String _sanitizeData(dynamic data) {
    if (data == null) return 'null';
    
    String dataStr = data.toString();
    
    // 비밀번호 패턴 마스킹
    dataStr = dataStr.replaceAllMapped(
      RegExp(r'"password"\s*:\s*"[^"]*"', caseSensitive: false),
      (match) => '"password": "***"',
    );
    
    // 토큰 패턴 마스킹
    dataStr = dataStr.replaceAllMapped(
      RegExp(r'"token"\s*:\s*"[^"]*"', caseSensitive: false),
      (match) => '"token": "***"',
    );
    
    return dataStr;
  }

  /// 레벨별 이모지
  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  /// 메시지 색상화 (개발 모드용)
  String _colorizeMessage(LogLevel level, String message) {
    if (!kDebugMode) return message;
    
    // ANSI 색상 코드
    const String reset = '\x1B[0m';
    String colorCode;
    
    switch (level) {
      case LogLevel.debug:
        colorCode = '\x1B[36m'; // Cyan
        break;
      case LogLevel.info:
        colorCode = '\x1B[32m'; // Green
        break;
      case LogLevel.warning:
        colorCode = '\x1B[33m'; // Yellow
        break;
      case LogLevel.error:
        colorCode = '\x1B[31m'; // Red
        break;
      case LogLevel.critical:
        colorCode = '\x1B[35m'; // Magenta
        break;
    }
    
    return '$colorCode$message$reset';
  }

  /// Developer 로그 레벨 변환
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
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

  factory LogStats.empty() {
    return const LogStats(
      fileCount: 0,
      totalLines: 0,
      totalSizeBytes: 0,
    );
  }

  double get totalSizeMB => totalSizeBytes / (1024 * 1024);

  @override
  String toString() {
    return 'LogStats(files: $fileCount, lines: $totalLines, size: ${totalSizeMB.toStringAsFixed(2)}MB)';
  }
}

/// 편의를 위한 전역 로거 인스턴스
final AppLogger logger = AppLogger.instance;