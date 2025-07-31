import 'package:actual/common/component/custom_text_form_field.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 뒤로가기 버튼
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // IconButton 너비만큼 여백
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // 에러 메시지 표시
                  Obx(() {
                    if (_authController.errorMessage.isNotEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _authController.errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  CustomTextFormField(
                    controller: _nameController,
                    hintText: '이름을 입력해주세요.',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이름을 입력해주세요.';
                      }
                      if (value.trim().length < 2) {
                        return '이름은 2자 이상이어야 합니다.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_authController.errorMessage.isNotEmpty) {
                        _authController.clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),

                  CustomTextFormField(
                    controller: _emailController,
                    hintText: '이메일을 입력해주세요.',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '올바른 이메일 형식을 입력해주세요.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_authController.errorMessage.isNotEmpty) {
                        _authController.clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),

                  CustomTextFormField(
                    controller: _passwordController,
                    hintText: '비밀번호를 입력해주세요.',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
                        return '비밀번호는 영문과 숫자를 포함해야 합니다.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_authController.errorMessage.isNotEmpty) {
                        _authController.clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),

                  CustomTextFormField(
                    controller: _confirmPasswordController,
                    hintText: '비밀번호를 다시 입력해주세요.',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호 확인을 입력해주세요.';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (_authController.errorMessage.isNotEmpty) {
                        _authController.clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 24.0),

                  Obx(() => FilledButton(
                    onPressed: _authController.isLoading ? null : _handleRegister,
                    child: _authController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("회원가입"),
                  )),

                  const SizedBox(height: 16.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("이미 계정이 있으신가요? "),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("로그인"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),
                  
                  // 이용약관 및 개인정보처리방침 동의
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      '회원가입 시 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authController.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success) {
      // 회원가입 성공 후 홈 화면으로 이동
      Get.offAll(() => const HomeScreen());
    }
  }
}