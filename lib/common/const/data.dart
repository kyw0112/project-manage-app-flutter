import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 조건부 import - dart:io는 웹에서 사용 불가
import 'dart:io' if (dart.library.html) 'dart:html' as platform;

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

//범용 스토리지
// 토큰 관리 페이지에서 불러와 read해서 토큰이 있는지 확인
final storage = FlutterSecureStorage();

// IP 설정 - 플랫폼별 최적화
final localhostIp = '127.0.0.1:3000';      // Web, Desktop (Windows, macOS, Linux)
final emulatorIp = '10.0.2.2:3000';       // Android Emulator  
final simulatorIp = '127.0.0.1:3000';     // iOS Simulator

/// 플랫폼별 서버 IP 반환
String get ip {
  if (kIsWeb) {
    return localhostIp; // 웹에서는 localhost 사용
  }
  
  try {
    // dart:io가 사용 가능한 경우 (모바일/데스크톱)
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.macOS) {
      return simulatorIp;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return emulatorIp;
    } else {
      // Windows, Linux 등 기타 데스크톱 플랫폼
      return localhostIp;
    }
  } catch (e) {
    // 플랫폼 감지 실패 시 기본값
    return localhostIp;
  }
}