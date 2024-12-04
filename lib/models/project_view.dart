import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_view.g.dart';

enum ViewKind { LIST, GANTT, TABLE, KANBAN }

@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectView {
  //"bucket_configuration": [],
  //"bucket_configuration_mode": 0,
  final DateTime created; // "created": "string",
  final int defaultBucketId; //": 0,
  final int doneBucketId;
  //"filter": "string",
  final int id; //": 0,
  final int position;
  final int projectId;
  final String title;
  final DateTime updated;
  final String viewKind;

  get icon {
    switch (viewKind) {
      case "list":
        return Icon(Icons.view_list);
      case "kanban":
        return Icon(Icons.view_kanban);
      default:
        return Icon(Icons.disabled_by_default_outlined);
    }
  }

  ProjectView(this.created, this.defaultBucketId, this.doneBucketId, this.id,
      this.position, this.projectId, this.title, this.updated, this.viewKind);

  factory ProjectView.fromJson(Map<String, dynamic> json) =>
      _$ProjectViewFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectViewToJson(this);

  ProjectView copyWith({
    DateTime? created, // "created": "string",
    int? defaultBucketId, //": 0,
    int? doneBucketId,
    int? id, //": 0,
    int? position,
    int? projectId,
    String? title,
    DateTime? updated,
    String? viewKind,
  }) {
    return ProjectView(
        created ?? this.created,
        defaultBucketId ?? this.defaultBucketId,
        doneBucketId ?? this.doneBucketId,
        id ?? this.id,
        position ?? this.position,
        projectId ?? this.projectId,
        title ?? this.title,
        updated ?? this.updated,
        viewKind ?? this.viewKind);
  }
}
