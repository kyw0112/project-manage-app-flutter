import 'package:actual/common/component/custom_text_form_field.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'package:actual/user/view/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  const _Title(),
                  const SizedBox(height: 16.0),
                  const _SubTitle(),
                  Image.asset('assets/img/misc/logo_img.png', height: 300),
                  
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
                      return null;
                    },
                    onChanged: (value) {
                      if (_authController.errorMessage.isNotEmpty) {
                        _authController.clearError();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  Obx(() => FilledButton(
                    onPressed: _authController.isLoading ? null : _handleLogin,
                    child: _authController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("로그인"),
                  )),
                  
                  TextButton(
                    onPressed: () {
                      Get.to(() => const RegisterScreen());
                    },
                    child: const Text("회원가입"),
                  ),
                  
                  TextButton(
                    onPressed: () {
                      // TODO: 비밀번호 찾기 화면으로 이동
                    },
                    child: const Text("비밀번호를 잊으셨나요?"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      Get.offAll(() => const HomeScreen());
    }
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '서로를 잇다.',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      "'이음'에 오신 것을 환영합니다.",
      style: TextStyle(fontSize: 18, color: colorScheme.primary),
    );
  }
}
