import 'package:actual/common/component/custom_header.dart';
import 'package:actual/common/widget/user_profile.dart';
import 'package:actual/my_project/model/member_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final int memberNo;
  final String team;
  final List<Map<String, String>> members;

  const TeamMemberCard(
      {super.key,
      required this.memberNo,
      required this.team,
      required this.members});

  factory TeamMemberCard.fromModel({required TeamMemberModel model}) {
    return TeamMemberCard(
      memberNo: model.memberNo,
      team: model.team.toString(),
      members: model.members,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print("팀 카드 tab! -> 상세 페이지 이동");
      },
      child: SizedBox(
        width: 50,
        height: 100,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                team,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10,),
              Stack(
                  children: List.generate(
                      members.length,
                      (index) => members[index] != null
                          ? profileContainer(
                              width: 36,
                              height: 36,
                              childWidget: customProfile(
                                  imageUrl: members[index]['imgUrl'].toString(),
                                  errorWidget: basicProfile))
                          : profileContainer(
                              width: 36, height: 36, childWidget: basicProfile))
                  )
            ],
          ),
        ),
      ),
    );
  }
}
