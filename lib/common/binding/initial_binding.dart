import 'package:actual/common/const/data.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:actual/user/repository/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Dio 인스턴스 생성
    Get.put<Dio>(_createDio(), permanent: true);
    
    // AuthRepository 등록
    Get.put<AuthRepository>(
      AuthRepositoryImpl(Get.find<Dio>()),
      permanent: true,
    );
    
    // AuthController 등록
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
  }

  Dio _createDio() {
    final dio = Dio();
    
    // Base URL 설정
    dio.options.baseUrl = 'http://$ip';
    
    // 기본 헤더 설정
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // 타임아웃 설정
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
    
    // 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 로깅
          print('[REQUEST] ${options.method} ${options.uri}');
          print('[REQUEST HEADERS] ${options.headers}');
          if (options.data != null) {
            print('[REQUEST DATA] ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 로깅
          print('[RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
          print('[RESPONSE DATA] ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          // 에러 로깅
          print('[ERROR] ${error.message}');
          print('[ERROR RESPONSE] ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
    
    // 토큰 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 인증이 필요한 API에 토큰 자동 추가
          if (_needsAuth(options.path)) {
            final authController = Get.find<AuthController>();
            if (authController.isAuthenticated) {
              final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
              if (accessToken != null) {
                options.headers['Authorization'] = 'Bearer $accessToken';
              }
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 에러 시 토큰 갱신 시도
          if (error.response?.statusCode == 401) {
            final authController = Get.find<AuthController>();
            if (authController.isAuthenticated) {
              final refreshSuccess = await authController.refreshToken();
              if (refreshSuccess) {
                // 토큰 갱신 성공 시 원래 요청 재시도
                final options = error.requestOptions;
                final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
                if (accessToken != null) {
                  options.headers['Authorization'] = 'Bearer $accessToken';
                }
                
                try {
                  final response = await dio.fetch(options);
                  handler.resolve(response);
                  return;
                } catch (e) {
                  // 재시도 실패 시 원래 에러 전달
                }
              }
            }
          }
          handler.next(error);
        },
      ),
    );
    
    return dio;
  }

  /// 인증이 필요한 API 경로인지 확인
  bool _needsAuth(String path) {
    // 로그인, 회원가입, 토큰 갱신 API는 인증 불필요
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];
    
    return !publicPaths.any((publicPath) => path.contains(publicPath));
  }
}