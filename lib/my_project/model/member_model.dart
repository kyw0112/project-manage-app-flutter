import 'package:actual/common/const/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member_model.g.dart';
@JsonSerializable()
class MemberModel {


  //dart run build_runner build 는 1회성
  //dart run build_runner watch 는 변경 추적해서 자동으로 재빌드
  //전환하고 싶은 속성 위에 JsonKey를 작성하면 됨.
  // @JsonKey(
  //   //fromJson일 때 실행할 함수 지정해주기
  //   fromJson: DataUtils.pathToUrl,
  //   // toJson: ,
  // )
  final int memberNo;
  // @JsonKey(
  //   //fromJson일 때 실행할 함수 지정해주기
  //   fromJson: ,
  //   // toJson: ,
  // )
  final String? name;
  // @JsonKey(
  //   //fromJson일 때 실행할 함수 지정해주기
  //   fromJson: ,
  //   // toJson: ,
  // )
  final String? imageUrl;
  // @JsonKey(
  //   //fromJson일 때 실행할 함수 지정해주기
  //   fromJson: ,
  //   // toJson: ,
  // )
  final int? role;
  // @JsonKey(
  //   //fromJson일 때 실행할 함수 지정해주기
  //   fromJson: ,
  //   // toJson: ,
  // )
  final String? label;



  MemberModel(
      {required this.memberNo,
      this.name,
      this.imageUrl,
      this.role,
      this.label});

  //json으로부터 인스턴스 생성하기
  factory MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);
  //json으로 인스턴스를 변환하기
  Map<String, dynamic> toJson() => _$MemberModelToJson(this);

  //JsonKey에 쓸 함수는 항상 static으로 선언해줘야 한다.
  //dataUtils로 이동함
  // static pathToUrl(String value){
  //     return 'http://$ip$value';
  // }

  // factory MemberModel.fromJson({
  //   required Map<String, dynamic> json,
  // }) {
  //   return MemberModel(
  //     memberNo: json['no'],
  //     name: json['name'],
  //     imageUrl: json['imageUrl'],
  //     role: json['role'],
  //   );
  // }
}


@JsonSerializable()
class TeamMemberModel {
  final int memberNo;
  final List<Map<String, String>> members;
  final String team;

  TeamMemberModel(
      {required this.memberNo,
        required this.members,
        required this.team,});

  //json으로부터 인스턴스 생성하기
  factory TeamMemberModel.fromJson(Map<String, dynamic> json) => _$TeamMemberModelFromJson(json);
  //json으로 인스턴스를 변환하기
  Map<String, dynamic> toJson() => _$TeamMemberModelToJson(this);

  // factory TeamMemberModel.fromJson({
  //   required Map<String, dynamic> json,
  // }) {
  //   return TeamMemberModel(
  //       memberNo: json['no'],
  //       members: json['members'],
  //       team: json['team']);
  // }
}
