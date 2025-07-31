import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // AuthController 초기화 완료까지 대기
    await Future.delayed(const Duration(milliseconds: 500));
    
    final authController = Get.find<AuthController>();
    
    // AuthController의 상태 변경을 감지
    ever(authController.statusRx, (AuthStatus status) {
      switch (status) {
        case AuthStatus.authenticated:
          Get.offAll(() => const HomeScreen());
          break;
        case AuthStatus.unauthenticated:
          Get.offAll(() => const LoginScreen());
          break;
        case AuthStatus.loading:
          // 로딩 상태는 스플래시 화면 유지
          break;
      }
    });
  }

  @override  
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return DefaultLayout(
      backgroundColor: colorScheme.primary,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo/logo.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            const SizedBox(height: 32.0),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              '이음',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSans',
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              '서로를 잇다',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'NotoSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}