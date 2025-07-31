import 'dart:convert';
import 'package:actual/common/const/data.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'auth_repository.g.dart';

@RestApi()
abstract class AuthRepository {
  factory AuthRepository(Dio dio, {String baseUrl}) = _AuthRepository;

  /// 로그인
  @POST('/auth/login')
  Future<LoginResponse> login(
    @Field('email') String email,
    @Field('password') String password,
  );

  /// 회원가입
  @POST('/auth/register')
  Future<LoginResponse> register(
    @Field('email') String email,
    @Field('password') String password,
    @Field('name') String name,
  );

  /// 로그아웃
  @POST('/auth/logout')
  Future<void> logout();

  /// 토큰 갱신
  @POST('/auth/refresh')
  Future<TokenResponse> refreshToken(@Field('refreshToken') String refreshToken);

  /// 현재 사용자 정보 가져오기
  @GET('/auth/me')
  Future<UserModel> getCurrentUser(@Header('Authorization') String accessToken);

  /// 프로필 업데이트
  @PUT('/auth/profile')
  Future<UserModel> updateProfile(@Body() UserModel user);

  /// 비밀번호 변경
  @PUT('/auth/password')
  Future<void> changePassword(
    @Field('currentPassword') String currentPassword,
    @Field('newPassword') String newPassword,
  );

  /// 비밀번호 재설정 요청
  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Field('email') String email);

  /// 비밀번호 재설정
  @POST('/auth/reset-password')
  Future<void> resetPassword(
    @Field('token') String token,
    @Field('password') String password,
  );

  /// 이메일 인증 요청
  @POST('/auth/verify-email')
  Future<void> sendEmailVerification();

  /// 이메일 인증 확인
  @POST('/auth/verify-email/confirm')
  Future<void> confirmEmailVerification(@Field('token') String token);
}

/// AuthRepository 구현 클래스 (개발용)
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final String _baseUrl;

  AuthRepositoryImpl(this._dio, {String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://$ip';

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      // Basic Auth 헤더 생성
      final credentials = base64Encode(utf8.encode('$email:$password'));
      
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/json',
          },
        ),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('서버 연결 시간이 초과되었습니다.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('서버에 연결할 수 없습니다.');
      } else {
        throw Exception('로그인 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<LoginResponse> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('이미 등록된 이메일입니다.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else {
        throw Exception('회원가입 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw Exception('예상치 못한 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(
        '$_baseUrl/auth/logout',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      // 로그아웃은 실패해도 클라이언트 상태를 초기화해야 함
      print('로그아웃 요청 실패: ${e.message}');
    }
  }

  @override
  Future<TokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return TokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('인증 정보가 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('토큰 갱신 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${accessToken.replaceAll('Bearer ', '')}',
            'Content-Type': 'application/json',
          },
        ),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('인증 정보가 유효하지 않습니다.');
      } else {
        throw Exception('사용자 정보를 가져오는 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/auth/profile',
        data: user.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else {
        throw Exception('프로필 업데이트 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.put(
        '$_baseUrl/auth/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('현재 비밀번호가 올바르지 않습니다.');
      } else {
        throw Exception('비밀번호 변경 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '$_baseUrl/auth/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('등록되지 않은 이메일입니다.');
      } else {
        throw Exception('비밀번호 재설정 요청 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      await _dio.post(
        '$_baseUrl/auth/reset-password',
        data: {
          'token': token,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('유효하지 않거나 만료된 토큰입니다.');
      } else {
        throw Exception('비밀번호 재설정 중 오료가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _dio.post(
        '$_baseUrl/auth/verify-email',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw Exception('이메일 전송 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<void> confirmEmailVerification(String token) async {
    try {
      await _dio.post(
        '$_baseUrl/auth/verify-email/confirm',
        data: {'token': token},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('유효하지 않거나 만료된 인증 토큰입니다.');
      } else {
        throw Exception('이메일 인증 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }
}