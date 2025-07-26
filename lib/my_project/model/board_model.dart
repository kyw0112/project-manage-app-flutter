import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';
@JsonSerializable()
class BoardModel {
  final String id;
  final String title;
  final String description;
  final List<String> managers;
  final List<String> labels;
  final String status;
  final Priority priority;
  final String startDate;
  final String deadLine;

  BoardModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.managers,
      required this.labels,
      required this.status,
      required this.priority,
      required this.startDate,
      required this.deadLine});

  
  factory BoardModel.fromJson(Map<String, dynamic> json)
  => _$BoardModelFromJson(json);
  
  //json으로부터 데이터를 받아온다
  // factory BoardModel.fromJson({
  //   required Map<String, dynamic> json,
  // }) {
  //   return BoardModel(
  //       id: json['id'],
  //       title: json['title'],
  //       description: json['description'],
  //       managers: json['managers'],
  //       labels: json['labels'],
  //       status: json['status'],
  //       priority: json['priority'],
  //       startDate: json['startDate'],
  //       deadLine: json['deadLine']);
  // }
}

enum Priority { veryLow, low, medium, high, veryHigh }