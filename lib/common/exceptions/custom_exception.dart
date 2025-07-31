/// 커스텀 예외 클래스들
abstract class CustomException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  final StackTrace? stackTrace;

  const CustomException({
    required this.message,
    required this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    return '$runtimeType: $message (Code: $code)';
  }

  /// 사용자에게 표시할 친화적인 메시지
  String get userFriendlyMessage => message;

  /// 에러 코드
  String get errorCode => code;

  /// 로깅용 상세 정보
  Map<String, dynamic> toJson() => {
    'type': runtimeType.toString(),
    'message': message,
    'code': code,
    'details': details,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// 네트워크 관련 예외
class NetworkException extends CustomException {
  final int? statusCode;
  final String? endpoint;

  const NetworkException({
    required super.message,
    required super.code,
    this.statusCode,
    this.endpoint,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
      case 401:
        return '인증이 필요합니다. 다시 로그인해주세요.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다.';
      case 408:
        return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
      case 429:
        return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요.';
      case 500:
        return '서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 502:
      case 503:
      case 504:
        return '서버가 일시적으로 사용할 수 없습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'statusCode': statusCode,
    'endpoint': endpoint,
  };
}

/// 인증 관련 예외
class AuthException extends CustomException {
  final AuthErrorType errorType;

  const AuthException({
    required super.message,
    required super.code,
    required this.errorType,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case AuthErrorType.userNotFound:
        return '등록되지 않은 사용자입니다.';
      case AuthErrorType.emailAlreadyExists:
        return '이미 등록된 이메일입니다.';
      case AuthErrorType.weakPassword:
        return '비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.';
      case AuthErrorType.tokenExpired:
        return '로그인이 만료되었습니다. 다시 로그인해주세요.';
      case AuthErrorType.tokenInvalid:
        return '인증 토큰이 유효하지 않습니다. 다시 로그인해주세요.';
      case AuthErrorType.accountLocked:
        return '계정이 잠겨있습니다. 관리자에게 문의하세요.';
      case AuthErrorType.tooManyAttempts:
        return '로그인 시도 횟수가 초과되었습니다. 잠시 후 다시 시도해주세요.';
      case AuthErrorType.emailNotVerified:
        return '이메일 인증이 필요합니다. 인증 메일을 확인해주세요.';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': errorType.name,
  };
}

enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  weakPassword,
  tokenExpired,
  tokenInvalid,
  accountLocked,
  tooManyAttempts,
  emailNotVerified,
}

/// 유효성 검사 예외
class ValidationException extends CustomException {
  final String field;
  final dynamic value;
  final List<String> violations;

  const ValidationException({
    required super.message,
    required super.code,
    required this.field,
    this.value,
    required this.violations,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    if (violations.isNotEmpty) {
      return violations.first;
    }
    return '입력 정보를 확인해주세요.';
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'field': field,
    'value': value,
    'violations': violations,
  };
}

/// 비즈니스 로직 예외
class BusinessException extends CustomException {
  final BusinessErrorType errorType;

  const BusinessException({
    required super.message,
    required super.code,
    required this.errorType,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    switch (errorType) {
      case BusinessErrorType.projectNotFound:
        return '프로젝트를 찾을 수 없습니다.';
      case BusinessErrorType.taskNotFound:
        return '작업을 찾을 수 없습니다.';
      case BusinessErrorType.insufficientPermission:
        return '권한이 부족합니다.';
      case BusinessErrorType.memberLimitExceeded:
        return '멤버 수 제한을 초과했습니다.';
      case BusinessErrorType.projectAlreadyCompleted:
        return '이미 완료된 프로젝트입니다.';
      case BusinessErrorType.taskAlreadyAssigned:
        return '이미 할당된 작업입니다.';
      case BusinessErrorType.duplicateResource:
        return '중복된 리소스입니다.';
      case BusinessErrorType.resourceInUse:
        return '사용 중인 리소스는 삭제할 수 없습니다.';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'errorType': errorType.name,
  };
}

enum BusinessErrorType {
  projectNotFound,
  taskNotFound,
  insufficientPermission,
  memberLimitExceeded,
  projectAlreadyCompleted,
  taskAlreadyAssigned,
  duplicateResource,
  resourceInUse,
}

/// 파일 관련 예외
class FileException extends CustomException {
  final String? fileName;
  final int? fileSize;
  final String? fileType;

  const FileException({
    required super.message,
    required super.code,
    this.fileName,
    this.fileSize,
    this.fileType,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'FILE_TOO_LARGE':
        return '파일 크기가 너무 큽니다. ${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
      case 'INVALID_FILE_TYPE':
        return '지원하지 않는 파일 형식입니다. ($fileType)';
      case 'FILE_NOT_FOUND':
        return '파일을 찾을 수 없습니다.';
      case 'UPLOAD_FAILED':
        return '파일 업로드에 실패했습니다. 다시 시도해주세요.';
      case 'DOWNLOAD_FAILED':
        return '파일 다운로드에 실패했습니다. 다시 시도해주세요.';
      default:
        return '파일 처리 중 오류가 발생했습니다.';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'fileName': fileName,
    'fileSize': fileSize,
    'fileType': fileType,
  };
}

/// 데이터베이스 관련 예외
class DatabaseException extends CustomException {
  final String? tableName;
  final String? operation;

  const DatabaseException({
    required super.message,
    required super.code,
    this.tableName,
    this.operation,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'CONNECTION_FAILED':
        return '데이터베이스 연결에 실패했습니다.';
      case 'QUERY_TIMEOUT':
        return '요청 처리 시간이 초과되었습니다.';
      case 'CONSTRAINT_VIOLATION':
        return '데이터 제약 조건에 위배됩니다.';
      case 'DUPLICATE_KEY':
        return '중복된 데이터입니다.';
      default:
        return '데이터 처리 중 오류가 발생했습니다.';
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'tableName': tableName,
    'operation': operation,
  };
}

/// 캐시 관련 예외
class CacheException extends CustomException {
  final String? cacheKey;

  const CacheException({
    required super.message,
    required super.code,
    this.cacheKey,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage => '임시 데이터 처리 중 오류가 발생했습니다.';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'cacheKey': cacheKey,
  };
}

/// 외부 서비스 관련 예외
class ExternalServiceException extends CustomException {
  final String serviceName;
  final String? serviceUrl;

  const ExternalServiceException({
    required super.message,
    required super.code,
    required this.serviceName,
    this.serviceUrl,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage => '$serviceName 서비스에 일시적인 문제가 발생했습니다.';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'serviceName': serviceName,
    'serviceUrl': serviceUrl,
  };
}

/// 타임아웃 관련 예외
class TimeoutException extends CustomException {
  final Duration timeout;
  final String operation;

  const TimeoutException({
    required super.message,
    required super.code,
    required this.timeout,
    required this.operation,
    super.details,
    super.stackTrace,
  });

  @override
  String get userFriendlyMessage => '요청 시간이 초과되었습니다. 다시 시도해주세요.';

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'timeout': timeout.inMilliseconds,
    'operation': operation,
  };
}

/// 예외 타입 확장 메소드
extension CustomExceptionExtension on Exception {
  /// Exception을 CustomException으로 변환
  CustomException toCustomException() {
    if (this is CustomException) {
      return this as CustomException;
    }
    
    final message = toString();
    
    // DioException 처리
    if (message.contains('DioException') || message.contains('DioError')) {
      return NetworkException(
        message: message,
        code: 'NETWORK_ERROR',
        details: this,
      );
    }
    
    // FormatException 처리
    if (this is FormatException) {
      return ValidationException(
        message: message,
        code: 'FORMAT_ERROR',
        field: 'unknown',
        violations: [message],
        details: this,
      );
    }
    
    // 기본 예외 처리
    return CustomException(
      message: message,
      code: 'UNKNOWN_ERROR',
      details: this,
    ) as CustomException;
  }
}

/// 예외 생성 헬퍼 클래스
class ExceptionFactory {
  static NetworkException networkError({
    required String message,
    int? statusCode,
    String? endpoint,
    dynamic details,
  }) {
    return NetworkException(
      message: message,
      code: 'NETWORK_ERROR_$statusCode',
      statusCode: statusCode,
      endpoint: endpoint,
      details: details,
    );
  }
  
  static AuthException authError({
    required String message,
    required AuthErrorType errorType,
    dynamic details,
  }) {
    return AuthException(
      message: message,
      code: 'AUTH_ERROR_${errorType.name.toUpperCase()}',
      errorType: errorType,
      details: details,
    );
  }
  
  static ValidationException validationError({
    required String field,
    required String message,
    dynamic value,
    List<String>? violations,
  }) {
    return ValidationException(
      message: message,
      code: 'VALIDATION_ERROR',
      field: field,
      value: value,
      violations: violations ?? [message],
    );
  }
  
  static BusinessException businessError({
    required String message,
    required BusinessErrorType errorType,
    dynamic details,
  }) {
    return BusinessException(
      message: message,
      code: 'BUSINESS_ERROR_${errorType.name.toUpperCase()}',
      errorType: errorType,
      details: details,
    );
  }
  
  static FileException fileError({
    required String message,
    required String code,
    String? fileName,
    int? fileSize,
    String? fileType,
  }) {
    return FileException(
      message: message,
      code: code,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );
  }
}