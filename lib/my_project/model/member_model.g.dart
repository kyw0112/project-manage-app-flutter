// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => MemberModel(
      memberNo: (json['memberNo'] as num).toInt(),
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      role: (json['role'] as num?)?.toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'memberNo': instance.memberNo,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'role': instance.role,
      'label': instance.label,
    };

TeamMemberModel _$TeamMemberModelFromJson(Map<String, dynamic> json) =>
    TeamMemberModel(
      memberNo: (json['memberNo'] as num).toInt(),
      members: (json['members'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      team: json['team'] as String,
    );

Map<String, dynamic> _$TeamMemberModelToJson(TeamMemberModel instance) =>
    <String, dynamic>{
      'memberNo': instance.memberNo,
      'members': instance.members,
      'team': instance.team,
    };
