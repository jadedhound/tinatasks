import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/models/task.dart';
import 'package:tinatasks/models/user.dart';
import 'package:tinatasks/theme/constants.dart';
import 'package:tinatasks/utils/json_converters.dart';

part 'label.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Label {
  final int id;
  final String title, description;
  final DateTime created, updated;
  final User createdBy;
  @JsonColorConverter()
  final Color? color;

  late final Color textColor = color != null && color!.computeLuminance() <= 0.5
      ? vLabelLight
      : vLabelDark;

  Label({
    this.id = 0,
    required this.title,
    this.description = '',
    this.color,
    DateTime? created,
    DateTime? updated,
    required this.createdBy,
  })  : this.created = created ?? DateTime.now(),
        this.updated = updated ?? DateTime.now();

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);
  Map<String, dynamic> toJson() => _$LabelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LabelTaskBulk {
  final List<Label> labels;

  LabelTaskBulk({required this.labels});

  factory LabelTaskBulk.fromJson(Map<String, dynamic> json) =>
      _$LabelTaskBulkFromJson(json);
  Map<String, dynamic> toJson() => _$LabelTaskBulkToJson(this);
}

//TODO: Remove this redundant class.
class LabelTask {
  final Label label;
  final Task? task;

  LabelTask({required this.label, required this.task});

  LabelTask.fromJson(Map<String, dynamic> json, User createdBy)
      : label =
            new Label(id: json['label_id'], title: '', createdBy: createdBy),
        task = null;

  toJSON() => {
        'label_id': label.id,
      };
}
