//정보와 데이터를 기반으로 어떤 페이지로 보내줘야 하는지 판단하는 기본 페이지
//목적1: 앱을 처음으로 열었을 때 토큰을 갖고 있는지 확인 -> 로그인 자동화, 일정 시간/기간 후 강제 로그아웃

import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    checkToken();
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
            const SizedBox(height: 16.0,),
            CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

void checkToken() async {
  //스토리지에 저장되어 있는 refresh, access 토큰 가져오기
  final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
  final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
  //유효성 검증 단계 필요
  final dio = Dio();
 
  try {
    final res = await dio.post(
      'http://$ip/auth/token',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    //자동 갱신 배우기 전, 5분 지나 토큰 만료될때마다 재로그인으로 처리...
    await storage.write(key: ACCESS_TOKEN_KEY, value: res.data['accessToken']);

    print('refreshToken 전송, accessToken을 재발급받았습니다.${res.data}');
    print('refreshToken: $refreshToken');
    Get.off(()=>HomeScreen());
  }catch(e){
    Get.to(()=>LoginScreen());
  }
}


//로그아웃할 때, 또는 만료됐을 때..? delete
void deleteToken() async {
  await storage.deleteAll();
}