import 'package:actual/common/widget/user_profile.dart';
import 'package:flutter/material.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Task> taskList = [
      Task(
        userName: "홍길동",
        userImage: "image.jpg",
        taskTitle: "작업1",
        taskPriority: "중요",
        taskIn: "board",
      ),
      Task(
        userName: "동길동",
        userImage: "image.jpg",
        taskTitle: "작업2",
        taskPriority: "보통",
        taskIn: "board",
      ),
      Task(
        userName: "옹길동",
        userImage: "image.jpg",
        taskTitle: "작업3",
        taskPriority: "덜 중요",
        taskIn: "board",
      ),
      Task(
        userName: "송길동",
        userImage: "image.jpg",
        taskTitle: "작업4",
        taskPriority: "가장 중요",
        taskIn: "board",
      ),
      Task(
        userName: "봉길동",
        userImage: "image.jpg",
        taskTitle: "작업5",
        taskPriority: "보통",
        taskIn: "board",
      ),
      Task(
        userName: "공길동",
        userImage: "image.jpg",
        taskTitle: "작업6",
        taskPriority: "덜 중요",
        taskIn: "board",
      ),
      Task(
        userName: "콩길동",
        userImage: "image.jpg",
        taskTitle: "작업7",
        taskPriority: "보통",
        taskIn: "board",
      ),
    ];

    //향후엔 api 요청해서 모든 작업 호출
    return SizedBox(
      child: ListView.builder(
          itemCount: taskList.length,
          itemBuilder: (BuildContext context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Tasks(
                  taskIn: taskList[index].taskIn,
                  taskTitle: taskList[index].taskTitle,
                  priority: taskList[index].taskPriority,
                  userImage: taskList[index].userImage,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            );
          }),
    );
  }
}

class _Tasks extends StatelessWidget {
  final String? taskIn;
  final String? taskTitle;
  final String? priority;
  final String? userImage;

  const _Tasks(
      {super.key,
      required this.taskIn,
      required this.taskTitle,
      required this.priority,
      required this.userImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              //아이콘
              taskIn == "board"
                  ? Icon(Icons.dashboard_customize)
                  : Icon(Icons.calendar_month),
              //제목
              SizedBox(
                width: 8,
              ),
              Text('$taskTitle'),
            ],
          ),
          Row(
            children: [
              //우선순위
              Text('$priority'),
              SizedBox(
                width: 10,
              ),
              //유저 프로필, 나중에 이미지로 바꿔주던지, 유저 이름은 커서 올렸을 때
              userImage != null
                  ? profileContainer(
                      width: 35,
                      height: 35,
                      childWidget: customProfile(
                          imageUrl: userImage.toString(),
                          errorWidget: basicProfile))
                  : profileContainer(
                      width: 35, height: 35, childWidget: basicProfile),
            ],
          )
        ],
      ),
    );
  }
}

class Task {
  final String userName;
  final String userImage;
  final String taskTitle;
  final String taskPriority;
  final String taskIn;

  Task({
    required this.userName,
    required this.userImage,
    required this.taskTitle,
    required this.taskPriority,
    required this.taskIn,
  });
}
