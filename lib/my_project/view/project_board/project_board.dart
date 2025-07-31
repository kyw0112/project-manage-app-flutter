import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:actual/user/controller/auth_controller.dart';
import 'kanban_board_screen.dart';

class ProjectBoard extends StatefulWidget {
  const ProjectBoard({Key? key}) : super(key: key);

  @override
  State<ProjectBoard> createState() => _ProjectBoardState();
}

class _ProjectBoardState extends State<ProjectBoard> {
  final AuthController _authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 현재 로그인한 사용자의 기본 프로젝트 ID를 사용
      // 실제로는 선택된 프로젝트 ID를 사용해야 함
      final currentUser = _authController.user;
      if (currentUser == null) {
        return const Center(
          child: Text('로그인이 필요합니다.'),
        );
      }
      
      // TODO: 실제 프로젝트 선택 로직 구현
      // 현재는 임시로 하드코딩된 프로젝트 ID 사용
      const projectId = "default-project-id";
      
      return KanbanBoardScreen(projectId: projectId);
    });
  }
}