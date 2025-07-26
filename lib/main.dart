import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/theme/material_theme.g.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(Typography.material2021().black).light().copyWith(
        textTheme: Typography.material2021().black.copyWith(
          bodyMedium: const TextStyle(fontFamily: 'NotoSans', color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), //버튼의 모서리 둥글기 설정
            )
          )
        ),
          filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), //버튼의 모서리 둥글기 설정
                  )
              )
          ),
      ),
      darkTheme: MaterialTheme(Typography.material2021().white).dark().copyWith(
        textTheme: Typography.material2021().white.copyWith(
          bodyMedium: const TextStyle(fontFamily: 'NotoSans'), // ✅ fontFamily 적용
        ),
      ),
      themeMode: ThemeMode.system,
      // home: SplashScreen(),
      //splash screen으로 나중에 대체하기
      home: SplashScreen(),
    );
  }
}
