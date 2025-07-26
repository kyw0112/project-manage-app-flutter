import 'dart:convert';
import 'dart:io';
import 'package:actual/common/component/custom_text_form_field.dart';
import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final storage = FlutterSecureStorage();
    // emulatorIp 는 10.0.2.2 가 로컬
    //simulatorIP 는 127.0.0.1로 동일
    // final simulatorIp = '127.0.0.1:3000';
    // final emulatorIp = '10.0.2.2:3000';
    // final ip = Platform.isIOS ? simulatorIp : emulatorIp;

    final username = 'test@codefactory.ai';
    final password = 'testtest';

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                _SubTitle(),
                Image.asset('assets/img/misc/logo_img.png', height: 300,),
                CustomTextFormField(
                  //test@codefactory.ai
                  hintText: '이메일을 입력해주세요.',
                  onChanged: (String value) {},
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  //testtest
                  hintText: '비밀번호를 입력해주세요.',
                  obscureText: true,
                  onChanged: (String value) {},
                ),
                const SizedBox(
                  height: 16.0,
                ),
                FilledButton(
                  child: Text("로그인"),
                  onPressed: () async {
                    try {
                      final rawString = '$username:$password';
                      Codec<String, String> stringToBase64 = utf8.fuse(base64);
                      String token = stringToBase64.encode(rawString);
                      
                      print("로그인 시도 중... 서버: http://$ip/auth/login");
                      
                      final res = await dio.post(
                        'http://$ip/auth/login',
                        options: Options(
                          headers: {
                            'authorization': 'Basic $token',
                          },
                          // 타임아웃 설정
                          sendTimeout: const Duration(seconds: 10),
                          receiveTimeout: const Duration(seconds: 10),
                        ),
                      );

                      final refreshToken = res.data['refreshToken'];
                      final accessToken = res.data['accessToken'];
                      await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                      await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

                      //토큰이 있는지 없는지, 유효한 토큰인지도 체크를 한 뒤 페이지 이동 시켜주는게 정석...
                      Get.off(()=> HomeScreen());
                      print("스토리지에 저장된 리프레시 토큰: $refreshToken");
                      print("스토리지에 저장된 액세스 토큰: $accessToken");
                    } catch (e) {
                      print("로그인 에러: $e");
                      // 서버가 없을 때 임시로 홈 화면으로 이동 (개발용)
                      if (e.toString().contains('SocketException') || 
                          e.toString().contains('Connection refused')) {
                        print("서버 연결 실패. 개발 모드로 홈 화면으로 이동합니다.");
                        Get.off(()=> HomeScreen());
                      } else {
                        // 다른 에러의 경우 사용자에게 알림
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('로그인에 실패했습니다: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                TextButton(
                  child: Text("회원가입"),
                  onPressed: () async {
                    // String refreshToken =
                    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc0MTA3NzEwMywiZXhwIjoxNzQxMTYzNTAzfQ.fFHrZenTdsUCPn1xFiZRoDsX5o8DvKZA7GVE-q9C268';
                    // final res = await dio.post(
                    //   'http://$ip/auth/token',
                    //   options: Options(
                    //     headers: {
                    //       'authorization': 'Bearer $refreshToken',
                    //     },
                    //   ),
                    // );
                    // print('refreshToken 전송, accessToken을 재발급받았습니다.${res.data}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
