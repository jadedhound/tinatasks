import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/models/project_view.dart';
import 'package:tinatasks/models/user.dart';
import 'package:tinatasks/utils/json_converters.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  final int id;
  final double position;
  final User? owner;
  final int parentProjectId;
  final String description;
  final String title;
  final DateTime created, updated;
  @JsonColorConverter()
  final Color? color;
  final bool isArchived, isFavourite;
  final List<ProjectView> views;
  Iterable<Project>? subprojects;

  Project(
      {this.id = 0,
      this.owner,
      this.parentProjectId = 0,
      this.description = '',
      this.position = 0,
      this.color,
      this.isArchived = false,
      this.isFavourite = false,
      this.views = const [],
      required this.title,
      created,
      updated})
      : this.created = created ?? DateTime.now(),
        this.updated = updated ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    int? id,
    DateTime? created,
    DateTime? updated,
    String? title,
    User? owner,
    String? description,
    int? parentProjectId,
    Color? color,
    bool? isArchived,
    bool? isFavourite,
    int? doneBucketId,
    double? position,
  }) {
    return Project(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      description: description ?? this.description,
      parentProjectId: parentProjectId ?? this.parentProjectId,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      isFavourite: isFavourite ?? this.isFavourite,
      position: position ?? this.position,
    );
  }
}
