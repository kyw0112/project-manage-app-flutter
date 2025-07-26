import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/home_screen.dart';
import 'package:actual/my_project/view/project_board/project_board.dart';
import 'package:actual/my_project/view/project_calendar.dart';
import 'package:actual/my_project/view/project_goto.dart';
import 'package:actual/my_project/view/project_member/project_member.dart';
import 'package:actual/my_project/view/project_task_lists.dart';
import 'package:actual/my_project/view/project_timeline.dart';
import 'package:actual/my_project/view/project_todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

class ProjectLayout extends StatelessWidget {
  ProjectLayout({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return DefaultLayout(
      title: "프로젝트명",
      actions: [
        IconButton(
            onPressed: () {
              Get.off(() => HomeScreen());
            },
            icon: Icon(Icons.home)),
        SizedBox(
          width: 10,
        )
      ],
      child: Scaffold(
        key: _key,
        drawer: ExampleSidebarX(controller: _controller),
        body: Row(
          children: [
            if (!isSmallScreen) ExampleSidebarX(controller: _controller),
            Expanded(
              child: Center(
                child: _ScreensExample(
                  controller: _controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Colors.amber,
        textStyle: TextStyle(color: Colors.black54),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.brown,
          ),
          color: Color(0XFF0D47A1),
        ),
        iconTheme: IconThemeData(
          color: Colors.indigo,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
      footerDivider: divider,
      headerBuilder: (context, extended) {
        return Container(
          height: 100,
          width: 120,
          margin: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.account_circle,
                size: 60,
              ),
              Text("김아무개"),
              SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.dashboard_customize,
          label: '보드',
          onTap: () {
            debugPrint('보드');
          },
        ),
        SidebarXItem(
          icon: Icons.list,
          label: '목록',
          selectable: false,
        ),
        SidebarXItem(
          icon: Icons.calendar_month,
          label: '캘린더',
          selectable: false,
        ),
        SidebarXItem(
          icon: Icons.timeline_rounded,
          label: '타임라인',
          selectable: false,
        ),
        SidebarXItem(
          icon: Icons.check_circle,
          label: 'Todo',
          selectable: false,
        ),
        const SidebarXItem(
          icon: Icons.link,
          label: '바로가기',
        ),
        SidebarXItem(
          icon: Icons.people,
          label: '멤버',
        ),
      ],
    );
  }
}

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final pageTitle = _getTitleByIndex(controller.selectedIndex);
          return pageTitle;
        });
  }
}

Widget _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return ProjectBoard();
    case 1:
      return ProjectTaskLists();
    case 2:
      return ProjectCalendar();
    case 3:
      return ProjectTimeline();
    case 4:
      return ProjectTodo();
    case 5:
      return ProjectGoto();
    case 6:
      return ProjectMember();
    default:
      return Center(child: Text('기본 화면'));
  }
}

final divider = Divider(color: Colors.white, height: 1);
