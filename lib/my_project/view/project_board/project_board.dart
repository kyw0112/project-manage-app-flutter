import 'package:flutter/material.dart';

import 'multi_board_list_example.dart';


class ProjectBoard extends StatefulWidget {
  const ProjectBoard({Key? key}) : super(key: key);

  @override
  State<ProjectBoard> createState() => _MyAppState();
}

class _MyAppState extends State<ProjectBoard> {
  int _currentIndex = 0;

  final List<Widget> _examples = [
    const MultiBoardListExample(),
    // const MultiBoardShrinkwrapListExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(color: Colors.white, child: _examples[_currentIndex]),
      ],
    );
  }
}