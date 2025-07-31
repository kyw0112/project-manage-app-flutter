import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/home/view/tasks_tab_bar_view/all_tasks_screen.dart';
import 'package:actual/home/view/tasks_tab_bar_view/my_task_screen.dart';
import 'package:actual/home/view/tasks_tab_bar_view/require_confirm_issue_screen.dart';
import 'package:actual/my_project/common/project_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

int _selectedIndex = 0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: DefaultLayout(
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(label: "홈", icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: "새로운 프로젝트", icon: Icon(Icons.add_box_outlined)),
            BottomNavigationBarItem(label: "내 프로필", icon: Icon(Icons.account_circle)),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(
                    title: '내 작업', fontSize: 18.0, fontWeight: FontWeight.w500),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Title(title: '최근 프로젝트', fontSize: 16.0),
                    TextButton(onPressed: () {}, child: Text("모든 프로젝트 보기")),
                  ],
                ),
                Row(
                  children: [
                    _RecentProjects(
                      projectTitle: "프로젝트 A",
                      unsolvedIssueCount: 23,
                      solvedIssueCount: 19,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    _RecentProjects(
                      projectTitle: "프로젝트 B",
                      unsolvedIssueCount: 23,
                      solvedIssueCount: 19,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  padding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    _TabWithBadge(title: "작업", count: 3),
                    _TabWithBadge(title: "나에게 할당된 작업", count: 10),
                    _TabWithBadge(title: "오늘의 Todo", count: 14),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      AllTasksScreen(),
                      MyTaskScreen(),
                      RequireConfirmIssueScreen(),
                    ],
                  ),
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
  final String title;
  final double? fontSize;
  final FontWeight? fontWeight;

  const _Title(
      {super.key,
      required this.title,
      this.fontSize = 16.0,
      this.fontWeight = FontWeight.normal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    );
  }
}

class _RecentProjects extends StatelessWidget {
  final String projectTitle;
  final int unsolvedIssueCount;
  final int solvedIssueCount;

  const _RecentProjects(
      {super.key,
      required this.projectTitle,
      required this.unsolvedIssueCount,
      required this.solvedIssueCount
      });

  //스토어 써야 해..

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: (){
        Get.off(()=> ProjectLayout());
      },
      child: Container(
        height: 120,
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: colorScheme.secondary),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                projectTitle,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("나의 미해결 작업"),
                  //미해결 이슈 몇건인지 나타내는 뱃지를 그리고 싶음
                  Badge(
                    label: Text("$unsolvedIssueCount"),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("완료된 작업"),
                  Badge(
                    label: Text("$solvedIssueCount"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabWithBadge extends StatelessWidget {
  final String title;
  final int? count;

  const _TabWithBadge({super.key, required this.title, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title), // 탭 텍스트
          SizedBox(
            width: 6,
          ),
          Badge(
            label: Text("$count"),
          ),
        ],
      ),
    );
  }
}
