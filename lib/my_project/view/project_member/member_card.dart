import 'package:actual/common/widget/user_profile.dart';
import 'package:actual/my_project/model/member_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  final int memberNo;
  final String name;
  final String? imageURL;
  final int? role;
  final double? height;

  const MemberCard(
      {super.key,
      required this.memberNo,
      required this.name,
      required this.imageURL,
      this.role,
      this.height});

  factory MemberCard.fromModel({
    required MemberModel model,
  }) {
    return MemberCard(
        memberNo: model.memberNo,
        name: model.name.toString(),
        role: model.role?.toInt(),
        imageURL: model.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("멤버 카드 tab! -> 상세 페이지 이동");
      },
      child: Card(
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageURL != null
                  ? profileContainer(
                      childWidget: customProfile(
                        imageUrl: imageURL.toString(),
                        errorWidget: basicProfile,
                      ),
                    )
                  : profileContainer(childWidget: basicProfile),
              SizedBox(
                height: 3,
              ),
              Text(
                name,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
