import 'package:actual/common/error/error_handler.dart';
import 'package:actual/common/logger/app_logger.dart';
import 'package:actual/common/network/dio_client.dart';
import 'package:actual/common/notification/notification_service.dart';
import 'package:actual/my_project/controller/board_controller.dart';
import 'package:actual/my_project/controller/calendar_controller.dart';
import 'package:actual/my_project/controller/project_controller.dart';
import 'package:actual/my_project/controller/task_controller.dart';
import 'package:actual/my_project/repository/calendar_repository.dart';
import 'package:actual/my_project/repository/project_repository.dart';
import 'package:actual/my_project/repository/task_repository.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:actual/user/controller/user_controller.dart';
import 'package:actual/user/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// 초기 의존성 주입 바인딩
class InitialBinding extends Bindings {
  /// 로거 인스턴스
  AppLogger get logger => AppLogger.instance;
  @override
  void dependencies() {
    // 1. 코어 서비스 초기화
    _initializeCoreServices();
    
    // 2. 네트워크 및 데이터 레이어 초기화
    _initializeNetworkLayer();
    
    // 3. Repository 레이어 초기화
    _initializeRepositories();
    
    // 4. Controller 레이어 초기화
    _initializeControllers();
    
    // 5. 전역 에러 핸들링 설정
    _setupGlobalErrorHandling();
  }

  /// 코어 서비스 초기화
  void _initializeCoreServices() {
    // 로거 초기화
    Get.put<AppLogger>(AppLogger.instance, permanent: true);
    
    // 에러 핸들러 초기화
    Get.put<ErrorHandler>(ErrorHandler(), permanent: true);
    
    // 알림 서비스 초기화
    Get.put<NotificationService>(NotificationService(), permanent: true);
    
    AppLogger.instance.info('Core services initialized');
  }

  /// 네트워크 레이어 초기화
  void _initializeNetworkLayer() {
    // DioClient 초기화
    final dioClient = DioClient();
    dioClient.initialize();
    Get.put<DioClient>(dioClient, permanent: true);
    
    // Dio 인스턴스를 별도로 등록 (기존 코드 호환성)
    Get.put<Dio>(dioClient.dio, permanent: true);
    
    AppLogger.instance.info('Network layer initialized');
  }

  /// Repository 레이어 초기화
  void _initializeRepositories() {
    final dio = Get.find<Dio>();
    
    // AuthRepository
    Get.put<AuthRepository>(
      AuthRepositoryImpl(dio),
      permanent: true,
    );
    
    // TaskRepository
    Get.put<TaskRepository>(
      TaskRepositoryImpl(dio),
      permanent: true,
    );
    
    // ProjectRepository
    Get.put<ProjectRepository>(
      ProjectRepositoryImpl(dio),
      permanent: true,
    );
    
    // CalendarRepository
    Get.put<CalendarRepository>(
      CalendarRepository(),
      permanent: true,
    );
    
    AppLogger.instance.info('Repository layer initialized');
  }

  /// Controller 레이어 초기화
  void _initializeControllers() {
    // AuthController (가장 먼저 초기화)
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
    
    // UserController
    Get.put<UserController>(
      UserController(),
      permanent: true,
    );
    
    // TaskController
    Get.put<TaskController>(
      TaskController(),
      permanent: true,
    );
    
    // ProjectController
    Get.put<ProjectController>(
      ProjectController(),
      permanent: true,
    );
    
    // BoardController (TaskController 이후에 초기화)
    Get.put<BoardController>(
      BoardController(),
      permanent: true,
    );
    
    AppLogger.instance.info('Controller layer initialized');
  }

  /// 전역 에러 핸들링 설정
  void _setupGlobalErrorHandling() {
    // Flutter 프레임워크 에러 처리 설정
    GlobalErrorHandlers.setupFlutterErrorHandling();
    
    AppLogger.instance.info('Global error handling configured');
  }
}

/// 지연 로딩 바인딩 (필요시 사용)
class LazyBinding extends Bindings {
  @override
  void dependencies() {
    // 필요할 때만 생성되는 의존성들
    Get.lazyPut<AppLogger>(() => AppLogger.instance);
    Get.lazyPut<ErrorHandler>(() => ErrorHandler());
  }
}

/// 페이지별 바인딩 (예시)
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 홈 페이지에서만 필요한 의존성들
    // 예: 대시보드 컨트롤러, 통계 서비스 등
  }
}

class ProjectBinding extends Bindings {
  @override
  void dependencies() {
    // 프로젝트 페이지에서만 필요한 의존성들
    // 이미 InitialBinding에서 등록되어 있으므로 추가 등록 불필요
    // 또는 특정 프로젝트 관련 추가 서비스들
  }
}

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    // 작업 페이지에서만 필요한 의존성들
    // 칸반 보드 컨트롤러, 실시간 업데이트 서비스 등
  }
}

/// 테스트용 바인딩
class TestBinding extends Bindings {
  @override
  void dependencies() {
    // 테스트에서 사용할 Mock 객체들
    // Get.put<AuthRepository>(MockAuthRepository());
    // Get.put<TaskRepository>(MockTaskRepository());
  }
}

/// 바인딩 유틸리티
class BindingUtils {
  /// 모든 컨트롤러가 초기화되었는지 확인
  static bool areControllersReady() {
    try {
      Get.find<AuthController>();
      Get.find<UserController>();
      Get.find<TaskController>();
      Get.find<ProjectController>();
      return true;
    } catch (e) {
      AppLogger.instance.warning('Some controllers are not ready: $e');
      return false;
    }
  }

  /// 의존성 상태 로깅
  static void logDependencyStatus() {
    final dependencies = [
      'AppLogger',
      'ErrorHandler',
      'DioClient',
      'AuthRepository',
      'TaskRepository',
      'ProjectRepository',
      'AuthController',
      'UserController',
      'TaskController',
      'ProjectController',
    ];

    AppLogger.instance.info('=== Dependency Status ===');
    for (final dep in dependencies) {
      try {
        Get.find(tag: dep);
        AppLogger.instance.info('✅ $dep: Ready');
      } catch (e) {
        AppLogger.instance.warning('❌ $dep: Not Ready');
      }
    }
  }

  /// 메모리 정리 (앱 종료 시)
  static void cleanup() {
    // 임시 데이터나 캐시 정리
    AppLogger.instance.info('Cleaning up dependencies...');
    
    // 파일 로깅 비활성화
    AppLogger.instance.disableFileLogging();
    
    // 에러 핸들러 비활성화
    ErrorHandler().disableErrorReporting();
    
    AppLogger.instance.info('Cleanup completed');
  }
}