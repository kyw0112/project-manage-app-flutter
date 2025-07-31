import 'package:actual/user/controller/auth_controller.dart';
import 'package:actual/user/model/user_model.dart' show UserModel, UserRole, UserStatus, LoginResponse;
import 'package:actual/user/repository/auth_repository.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum UserLoadingState { idle, loading, success, error }

class UserController extends GetxController {
  static UserController get to => Get.find();
  
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Reactive variables
  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  final RxList<UserModel> _users = <UserModel>[].obs;
  final Rx<UserLoadingState> _loadingState = UserLoadingState.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isProfileUpdateLoading = false.obs;
  final RxBool _isPasswordChangeLoading = false.obs;
  final RxBool _isImageUploadLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  
  // Getters
  UserModel? get currentUser => _currentUser.value;
  List<UserModel> get users => _users;
  UserLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  bool get isProfileUpdateLoading => _isProfileUpdateLoading.value;
  bool get isPasswordChangeLoading => _isPasswordChangeLoading.value;
  bool get isImageUploadLoading => _isImageUploadLoading.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _loadingState.value == UserLoadingState.loading;
  bool get hasError => _loadingState.value == UserLoadingState.error;
  
  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }
  
  /// 현재 사용자 정보 로드
  Future<void> _loadCurrentUser() async {
    try {
      _loadingState.value = UserLoadingState.loading;
      _errorMessage.value = '';
      
      // AuthController에서 현재 사용자 정보 가져오기
      final authController = Get.find<AuthController>();
      if (authController.user != null) {
        _currentUser.value = authController.user;
        _loadingState.value = UserLoadingState.success;
      } else {
        _loadingState.value = UserLoadingState.error;
        _errorMessage.value = '사용자 정보를 찾을 수 없습니다.';
      }
    } catch (e) {
      _loadingState.value = UserLoadingState.error;
      _errorMessage.value = '사용자 정보 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 현재 사용자 정보 새로고침
  Future<void> refreshCurrentUser() async {
    await _loadCurrentUser();
  }
  
  /// 사용자 정보 설정 (외부에서 호출)
  void setCurrentUser(UserModel user) {
    _currentUser.value = user;
  }
  
  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
    String? department,
    String? position,
    String? phone,
    String? bio,
  }) async {
    try {
      _isProfileUpdateLoading.value = true;
      _errorMessage.value = '';
      
      if (_currentUser.value == null) {
        _errorMessage.value = '사용자 정보가 없습니다.';
        return false;
      }
      
      // 유효성 검사
      if (name != null && name.trim().isEmpty) {
        _errorMessage.value = '이름을 입력해주세요.';
        return false;
      }
      
      if (email != null && !_isValidEmail(email)) {
        _errorMessage.value = '올바른 이메일 형식을 입력해주세요.';
        return false;
      }
      
      // 업데이트된 사용자 정보 생성
      final updatedUser = _currentUser.value!.copyWith(
        name: name,
        email: email,
        profileImage: profileImageUrl,
        department: department,
        position: position,
        phoneNumber: phone,
      );
      
      // API 호출
      final result = await _authRepository.updateProfile(updatedUser);
      _currentUser.value = result;
      
      // AuthController에도 업데이트 반영
      final authController = Get.find<AuthController>();
      authController.updateUserInfo(result);
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로필 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isProfileUpdateLoading.value = false;
    }
  }
  
  /// 비밀번호 변경
  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      _isPasswordChangeLoading.value = true;
      _errorMessage.value = '';
      
      // 유효성 검사
      if (currentPassword.isEmpty) {
        _errorMessage.value = '현재 비밀번호를 입력해주세요.';
        return false;
      }
      
      if (newPassword.length < 6) {
        _errorMessage.value = '새 비밀번호는 6자 이상이어야 합니다.';
        return false;
      }
      
      if (newPassword != confirmPassword) {
        _errorMessage.value = '새 비밀번호와 확인 비밀번호가 일치하지 않습니다.';
        return false;
      }
      
      if (currentPassword == newPassword) {
        _errorMessage.value = '새 비밀번호는 현재 비밀번호와 달라야 합니다.';
        return false;
      }
      
      // 비밀번호 강도 검사
      if (!_isStrongPassword(newPassword)) {
        _errorMessage.value = '비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다.';
        return false;
      }
      
      await _authRepository.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _errorMessage.value = '비밀번호 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isPasswordChangeLoading.value = false;
    }
  }
  
  /// 프로필 이미지 선택 및 업로드
  Future<bool> updateProfileImage({ImageSource source = ImageSource.gallery}) async {
    try {
      _isImageUploadLoading.value = true;
      _errorMessage.value = '';
      
      // 이미지 선택
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile == null) {
        return false; // 사용자가 취소함
      }
      
      // TODO: 실제 이미지 업로드 API 연동
      // 현재는 로컬 파일 경로를 임시로 사용
      final imageUrl = pickedFile.path;
      
      // 프로필 업데이트
      return await updateProfile(profileImageUrl: imageUrl);
    } catch (e) {
      _errorMessage.value = '이미지 업로드 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isImageUploadLoading.value = false;
    }
  }
  
  /// 프로필 이미지 제거
  Future<bool> removeProfileImage() async {
    return await updateProfile(profileImageUrl: '');
  }
  
  /// 사용자 검색 (프로젝트 멤버 초대 등에서 사용)
  Future<List<UserModel>?> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      
      _searchQuery.value = query;
      
      // TODO: 실제 사용자 검색 API 연동
      // 현재는 임시 데이터로 대체
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockUsers = <UserModel>[
        UserModel(
          id: '1',
          email: 'user1@example.com',
          name: '김사용자',
          role: UserRole.member,
          status: UserStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          email: 'user2@example.com',
          name: '이개발자',
          role: UserRole.member,
          status: UserStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // 검색어로 필터링
      final filtered = mockUsers.where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      _users.assignAll(filtered);
      return filtered;
    } catch (e) {
      _errorMessage.value = '사용자 검색 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 계정 삭제 (탈퇴)
  Future<bool> deleteAccount(String password) async {
    try {
      _loadingState.value = UserLoadingState.loading;
      _errorMessage.value = '';
      
      if (password.isEmpty) {
        _errorMessage.value = '비밀번호를 입력해주세요.';
        return false;
      }
      
      // TODO: 실제 계정 삭제 API 연동
      await Future.delayed(const Duration(seconds: 1));
      
      // 로그아웃 처리
      final authController = Get.find<AuthController>();
      await authController.logout();
      
      _currentUser.value = null;
      _loadingState.value = UserLoadingState.success;
      
      return true;
    } catch (e) {
      _loadingState.value = UserLoadingState.error;
      _errorMessage.value = '계정 삭제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 사용자 설정 업데이트
  Future<bool> updateSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? darkMode,
    String? language,
    String? timezone,
  }) async {
    try {
      _errorMessage.value = '';
      
      if (_currentUser.value == null) {
        _errorMessage.value = '사용자 정보가 없습니다.';
        return false;
      }
      
      // TODO: 실제 설정 업데이트 API 연동
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 로컬 설정 업데이트 (임시)
      // 실제로는 UserModel에 settings 필드를 추가하고 API에서 처리
      
      return true;
    } catch (e) {
      _errorMessage.value = '설정 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 사용자 활동 로그 조회
  Future<List<UserActivity>?> getUserActivity({int limit = 20}) async {
    try {
      // TODO: 실제 활동 로그 API 연동
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 임시 데이터
      final activities = <UserActivity>[
        UserActivity(
          id: '1',
          type: UserActivityType.login,
          description: '로그인',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        UserActivity(
          id: '2',
          type: UserActivityType.profileUpdate,
          description: '프로필 업데이트',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        UserActivity(
          id: '3',
          type: UserActivityType.projectCreate,
          description: '새 프로젝트 생성: 모바일 앱 개발',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      return activities;
    } catch (e) {
      _errorMessage.value = '활동 로그 조회 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 알림 설정 업데이트
  Future<bool> updateNotificationSettings({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? projectUpdates,
    bool? taskAssigned,
    bool? taskDue,
    bool? teamInvites,
  }) async {
    try {
      // TODO: 실제 알림 설정 API 연동
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      _errorMessage.value = '알림 설정 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage.value = '';
  }
  
  /// 검색 쿼리 클리어
  void clearSearch() {
    _searchQuery.value = '';
    _users.clear();
  }
  
  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// 비밀번호 강도 검사
  bool _isStrongPassword(String password) {
    // 최소 6자, 영문, 숫자, 특수문자 포함
    if (password.length < 6) return false;
    
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasLetter && hasDigit && hasSpecial;
  }
  
  /// 사용자 상태 확인
  bool get isLoggedIn => _currentUser.value != null;
  
  /// 사용자 권한 확인
  bool hasRole(UserRole role) {
    return _currentUser.value?.role == role;
  }
  
  /// 사용자 프로필 완성도 계산
  double get profileCompleteness {
    if (_currentUser.value == null) return 0.0;
    
    final user = _currentUser.value!;
    int completedFields = 0;
    int totalFields = 6; // name, email, profileImage, department, position, phoneNumber
    
    if (user.name.isNotEmpty) completedFields++;
    if (user.email.isNotEmpty) completedFields++;
    if (user.profileImageUrl?.isNotEmpty == true) completedFields++;
    if (user.department?.isNotEmpty == true) completedFields++;
    if (user.position?.isNotEmpty == true) completedFields++;
    if (user.phoneNumber?.isNotEmpty == true) completedFields++;
    // bio field는 UserModel에 없으므로 제거
    
    return completedFields / totalFields;
  }
  
  /// 사용자 가입 경과 일수
  int? get daysSinceJoined {
    if (_currentUser.value == null) return null;
    
    final joinDate = _currentUser.value!.createdAt;
    final now = DateTime.now();
    return now.difference(joinDate).inDays;
  }
}

/// 사용자 활동 모델
class UserActivity {
  final String id;
  final UserActivityType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const UserActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}

/// 사용자 활동 타입
enum UserActivityType {
  login,
  logout,
  profileUpdate,
  passwordChange,
  projectCreate,
  projectJoin,
  taskCreate,
  taskComplete,
  fileUpload,
  commentAdd,
}


extension AuthControllerExtension on AuthController {
  void updateUserInfo(UserModel user) {
    // AuthController의 사용자 정보 업데이트
    // 실제 AuthController에 이 메소드가 있어야 함
  }
}