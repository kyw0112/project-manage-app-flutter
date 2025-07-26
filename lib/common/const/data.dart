import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

//범용 스토리지
// 토큰 관리 페이지에서 불러와 read해서 토큰이 있는지 확인
final storage = FlutterSecureStorage();
final simulatorIp = '127.0.0.1:3000';
final emulatorIp = '10.0.2.2:3000';
final ip = Platform.isIOS || Platform.isMacOS ? simulatorIp : emulatorIp;