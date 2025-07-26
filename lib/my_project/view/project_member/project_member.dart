import 'package:actual/common/component/custom_header.dart';
import 'package:actual/my_project/model/member_model.dart';
import 'package:actual/my_project/view/project_member/member_card.dart';
import 'package:actual/my_project/view/project_member/team_member_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectMember extends StatelessWidget {
  const ProjectMember({super.key});

  Future<List> paginateMember() async {
    // final dio = Dio();
    // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    // final resp = await dio.get('http://$ip/member', options:
    // Options(
    //     headers: {
    //       'authorization': 'Bearer $accessToken',
    //     }
    // )
    // );
    // return resp.data['data'];

    final List<Map<String, dynamic>> members = [
      {"no": 0, "name": "백설공주", "role": 200, "team": "Team_SnowWhite"},
      {
        "no": 1,
        "name": "신데렐라",
        "role": 100,
      },
      {
        "no": 2,
        "name": "인어공주",
        "role": 200,
      },
      {"no": 3, "name": "난쟁이1", "role": 100, "team": "Team_SnowWhite"},
      {"no": 4, "name": "난쟁이2", "role": 100, "team": "Team_SnowWhite"},
      {
        "no": 5,
        "name": "벨라",
        "role": 100,
      },
    ];
    return members;
  }

  Future<List> paginateTeam() async {
    // final dio = Dio();
    // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    // final resp = await dio.get('http://$ip/member', options:
    // Options(
    //     headers: {
    //       'authorization': 'Bearer $accessToken',
    //     }
    // )
    // );
    // return resp.data['data'];

    final List<Map<String, dynamic>> members = [
      {
        "no": 0,
        "members": [
          {'name': '백설공주', 'imgUrl': 'assets/img/user/user_basic_icon.png'},
          {'name': '난장이1', 'imgUrl': 'assets/img/user/user_basic_icon.png'},
          {'name': '난장이2', 'imgUrl': 'assets/img/user/user_basic_icon.png'}
        ],
        "team": "Team_SnowWhite"
      },
      {
        "no": 0,
        "members": [
          {'name': '인어공주', 'imgUrl': 'assets/img/user/user_basic_icon.png'},
          {'name': '신데렐라', 'imgUrl': 'assets/img/user/user_basic_icon.png'},
          {'name': '벨라', 'imgUrl': 'assets/img/user/user_basic_icon.png'}
        ],
        "team": "Team_Princess"
      },
    ];
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CustomHeader(title: "사용자 및 팀"),
          SizedBox(
            height: 10,
          ),
          SearchBar(
            leading: Icon(Icons.search),
            hintText: "사용자 및 팀 검색",
            padding:
                MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15)),
          ),
          SizedBox(
            height: 25,
          ),
          CustomHeader(
            title: "사용자",
            fontSize: 16,
            buttonName: '추가하기',
            onClicked: () {},
          ),
          FutureBuilder(
              future: paginateMember(),
              builder: (context, AsyncSnapshot<List> snapshot) {
                print(snapshot.data);
                if (!snapshot.hasData) {
                  return Container();
                }
                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        final item = snapshot.data![index];
                        final pItem = MemberModel.fromJson(item);
                        return MemberCard.fromModel(model: pItem);
                      },
                      separatorBuilder: (_, index) {
                        return SizedBox(
                          width: 6,
                        );
                      },
                      itemCount: snapshot.data!.length),
                );
              }),
          SizedBox(
            height: 20,
          ),
          CustomHeader(
            title: "내 팀",
            fontSize: 16,
          ),
          FutureBuilder(
              future: paginateTeam(),
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (!snapshot.hasData) {
                  return Text("로딩 중..");
                }
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: ListView.separated(
                      itemBuilder: (_, index) {
                        final item = snapshot.data![index];
                        final pItem = TeamMemberModel.fromJson(item);
                        return TeamMemberCard.fromModel(model: pItem);
                      },

                      separatorBuilder: (_, index) => SizedBox(
                            height: 12,
                          ),
                      itemCount: snapshot.data!.length),
                );
              })
        ],
      ),
    );
  }
}
