import 'package:actual/common/const/data.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/repository/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Reactive variables
  final Rx<AuthStatus> _status = AuthStatus.loading.obs;
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  
  // Getters
  AuthStatus get status => _status.value;
  Rx<AuthStatus> get statusRx => _status;
  UserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isAuthenticated => _status.value == AuthStatus.authenticated;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }
  
  /// 앱 시작 시 저장된 토큰으로 인증 상태 확인
  Future<void> _checkAuthStatus() async {
    try {
      _status.value = AuthStatus.loading;
      
      final accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
      final refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);
      
      if (accessToken != null && refreshToken != null) {
        // 토큰이 있으면 사용자 정보 가져오기
        final user = await _authRepository.getCurrentUser(accessToken);
        _user.value = user;
        _status.value = AuthStatus.authenticated;
      } else {
        _status.value = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status.value = AuthStatus.unauthenticated;
      _errorMessage.value = '인증 상태 확인 중 오류가 발생했습니다.';
    }
  }
  
  /// 로그인
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      // 입력 유효성 검사
      if (!_isValidEmail(email)) {
        _errorMessage.value = '올바른 이메일 형식을 입력해주세요.';
        return false;
      }
      
      if (password.length < 6) {
        _errorMessage.value = '비밀번호는 6자 이상이어야 합니다.';
        return false;
      }
      
      final result = await _authRepository.login(email, password);
      
      // 토큰 저장
      await _storage.write(key: ACCESS_TOKEN_KEY, value: result.accessToken);
      await _storage.write(key: REFRESH_TOKEN_KEY, value: result.refreshToken);
      
      // 사용자 정보 설정
      _user.value = result.user;
      _status.value = AuthStatus.authenticated;
      
      return true;
    } catch (e) {
      _errorMessage.value = '로그인에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 로그아웃
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      // 서버에 로그아웃 요청
      await _authRepository.logout();
      
      // 로컬 토큰 삭제
      await _storage.delete(key: ACCESS_TOKEN_KEY);
      await _storage.delete(key: REFRESH_TOKEN_KEY);
      
      // 상태 초기화
      _user.value = null;
      _status.value = AuthStatus.unauthenticated;
      _errorMessage.value = '';
      
    } catch (e) {
      // 로그아웃은 실패해도 로컬 상태는 초기화
      await _storage.delete(key: ACCESS_TOKEN_KEY);
      await _storage.delete(key: REFRESH_TOKEN_KEY);
      _user.value = null;
      _status.value = AuthStatus.unauthenticated;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 회원가입
  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      // 입력 유효성 검사
      if (!_isValidEmail(email)) {
        _errorMessage.value = '올바른 이메일 형식을 입력해주세요.';
        return false;
      }
      
      if (password.length < 6) {
        _errorMessage.value = '비밀번호는 6자 이상이어야 합니다.';
        return false;
      }
      
      if (name.trim().isEmpty) {
        _errorMessage.value = '이름을 입력해주세요.';
        return false;
      }
      
      final result = await _authRepository.register(email, password, name);
      
      // 회원가입 후 자동 로그인
      await _storage.write(key: ACCESS_TOKEN_KEY, value: result.accessToken);
      await _storage.write(key: REFRESH_TOKEN_KEY, value: result.refreshToken);
      
      _user.value = result.user;
      _status.value = AuthStatus.authenticated;
      
      return true;
    } catch (e) {
      _errorMessage.value = '회원가입에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);
      if (refreshToken == null) {
        await logout();
        return false;
      }
      
      final result = await _authRepository.refreshToken(refreshToken);
      
      await _storage.write(key: ACCESS_TOKEN_KEY, value: result.accessToken);
      await _storage.write(key: REFRESH_TOKEN_KEY, value: result.refreshToken);
      
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }
  
  /// 사용자 정보 업데이트
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final user = await _authRepository.updateProfile(updatedUser);
      _user.value = user;
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로필 업데이트에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 비밀번호 변경
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      if (newPassword.length < 6) {
        _errorMessage.value = '새 비밀번호는 6자 이상이어야 합니다.';
        return false;
      }
      
      await _authRepository.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _errorMessage.value = '비밀번호 변경에 실패했습니다: ${e.toString()}';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage.value = '';
  }
  
  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}