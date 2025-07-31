import 'dart:async';

import 'package:actual/user/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 인증 미들웨어 - 라우트 보호 및 권한 확인
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // 인증이 필요한 라우트 목록
    final protectedRoutes = [
      '/home',
      '/project',
      '/task',
      '/calendar',
      '/timeline',
      '/todo',
      '/profile',
      '/settings',
    ];
    
    // 현재 라우트가 보호된 라우트인지 확인
    final isProtectedRoute = protectedRoutes.any((protectedRoute) => 
        route?.startsWith(protectedRoute) == true);
    
    // 인증이 필요한 라우트인데 로그인되지 않은 경우
    if (isProtectedRoute && !authController.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }
    
    // 이미 로그인된 상태에서 로그인/회원가입 페이지 접근 시
    if (authController.isAuthenticated && 
        (route == '/login' || route == '/register')) {
      return const RouteSettings(name: '/home');
    }
    
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    // 페이지 호출 시 추가 로직
    return page;
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    // 바인딩 시작 시 추가 로직
    return bindings;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    // 페이지 빌드 시작 시 추가 로직
    return page;
  }
}

/// 관리자 권한 미들웨어
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // 관리자 권한이 필요한 라우트 목록
    final adminRoutes = [
      '/admin',
      '/settings/admin',
      '/users/manage',
    ];
    
    // 현재 라우트가 관리자 라우트인지 확인
    final isAdminRoute = adminRoutes.any((adminRoute) => 
        route?.startsWith(adminRoute) == true);
    
    if (isAdminRoute) {
      // 로그인되지 않은 경우
      if (!authController.isAuthenticated) {
        return const RouteSettings(name: '/login');
      }
      
      // 관리자 권한이 없는 경우
      // TODO: UserModel에 role 필드 추가 후 권한 확인
      // if (!authController.user?.isAdmin == true) {
      //   return const RouteSettings(name: '/unauthorized');
      // }
    }
    
    return null;
  }
}

/// 권한 기반 미들웨어
class PermissionMiddleware extends GetMiddleware {
  final String requiredPermission;
  
  PermissionMiddleware({required this.requiredPermission});

  @override
  int? get priority => 3;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // 로그인되지 않은 경우
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }
    
    // 권한 확인
    // TODO: 사용자 권한 시스템 구현 후 권한 확인 로직 추가
    // if (!authController.user?.hasPermission(requiredPermission) == true) {
    //   return const RouteSettings(name: '/unauthorized');
    // }
    
    return null;
  }
}

/// 인증 가드 - 위젯 레벨에서 인증 상태 확인
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool requireAuth;
  final String? requiredPermission;
  final VoidCallback? onUnauthorized;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
    this.requireAuth = true,
    this.requiredPermission,
    this.onUnauthorized,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // 인증이 필요한데 로그인되지 않은 경우
        if (requireAuth && !authController.isAuthenticated) {
          if (onUnauthorized != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onUnauthorized!();
            });
          }
          
          return fallback ?? const _UnauthorizedWidget();
        }
        
        // 특정 권한이 필요한 경우
        if (requiredPermission != null && authController.isAuthenticated) {
          // TODO: 권한 확인 로직 구현
          // if (!authController.user?.hasPermission(requiredPermission!) == true) {
          //   return fallback ?? const _UnauthorizedWidget();
          // }
        }
        
        return child;
      },
    );
  }
}

/// 권한 없음 화면
class _UnauthorizedWidget extends StatelessWidget {
  const _UnauthorizedWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('접근 권한 없음'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '이 페이지에 접근할 권한이 없습니다.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '로그인하거나 관리자에게 문의하세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로딩 상태를 고려한 인증 가드
class AuthLoadingGuard extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthorizedWidget;

  const AuthLoadingGuard({
    super.key,
    required this.child,
    this.loadingWidget,
    this.unauthorizedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // 인증 상태 로딩 중
        if (authController.status == AuthStatus.loading) {
          return loadingWidget ?? const _LoadingWidget();
        }
        
        // 인증되지 않은 경우
        if (authController.status == AuthStatus.unauthenticated) {
          return unauthorizedWidget ?? const _UnauthorizedWidget();
        }
        
        // 인증된 경우
        return child;
      },
    );
  }
}

/// 로딩 위젯
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '인증 상태를 확인하는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 조건부 인증 가드
class ConditionalAuthGuard extends StatelessWidget {
  final Widget child;
  final bool Function() condition;
  final Widget? fallback;

  const ConditionalAuthGuard({
    super.key,
    required this.child,
    required this.condition,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        if (condition()) {
          return child;
        } else {
          return fallback ?? const _UnauthorizedWidget();
        }
      },
    );
  }
}

/// 세션 타임아웃 가드
class SessionTimeoutGuard extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback? onTimeout;

  const SessionTimeoutGuard({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 30),
    this.onTimeout,
  });

  @override
  State<SessionTimeoutGuard> createState() => _SessionTimeoutGuardState();
}

class _SessionTimeoutGuardState extends State<SessionTimeoutGuard> {
  Timer? _timeoutTimer;
  DateTime _lastActivity = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final timeSinceLastActivity = now.difference(_lastActivity);
      
      if (timeSinceLastActivity >= widget.timeout) {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timeoutTimer?.cancel();
    
    if (widget.onTimeout != null) {
      widget.onTimeout!();
    } else {
      // 기본 타임아웃 처리: 로그아웃
      final authController = Get.find<AuthController>();
      authController.logout();
      
      Get.snackbar(
        '세션 만료',
        '로그인 세션이 만료되었습니다. 다시 로그인해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void _updateActivity() {
    _lastActivity = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _updateActivity,
      onPanUpdate: (_) => _updateActivity(),
      onScaleUpdate: (_) => _updateActivity(),
      child: widget.child,
    );
  }
}

/// 자동 로그아웃 기능
class AutoLogoutManager {
  static final AutoLogoutManager _instance = AutoLogoutManager._internal();
  factory AutoLogoutManager() => _instance;
  AutoLogoutManager._internal();

  Timer? _logoutTimer;
  Duration _timeout = const Duration(minutes: 30);
  
  /// 자동 로그아웃 활성화
  void enable({Duration? timeout}) {
    if (timeout != null) {
      _timeout = timeout;
    }
    
    _resetTimer();
  }

  /// 자동 로그아웃 비활성화
  void disable() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  /// 타이머 리셋 (사용자 활동 시 호출)
  void resetTimer() {
    _resetTimer();
  }

  void _resetTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(_timeout, () {
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated) {
        authController.logout();
        
        Get.snackbar(
          '자동 로그아웃',
          '일정 시간 동안 활동이 없어 자동으로 로그아웃되었습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }
}