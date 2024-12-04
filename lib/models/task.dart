import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/models/label.dart';
import 'package:tinatasks/models/task_attachment.dart';
import 'package:tinatasks/models/user.dart';
import 'package:tinatasks/utils/checkboxes_in_text.dart';
import 'package:tinatasks/utils/json_converters.dart';

part 'task.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskReminder {
  final int relativePeriod;
  final String relativeTo;
  DateTime reminder;

  TaskReminder(this.reminder)
      : relativePeriod = 0,
        relativeTo = "";

  factory TaskReminder.fromJson(Map<String, dynamic> json) =>
      _$TaskReminderFromJson(json);
  Map<String, dynamic> toJson() => _$TaskReminderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Task {
  final int id;
  final int? parentTaskId, priority, bucketId;
  //final int? listId;
  final int? projectId;
  final DateTime created, updated;
  DateTime? dueDate, startDate, endDate;
  final List<TaskReminder> reminderDates;
  final String identifier;
  final String title, description;
  final bool done;
  @JsonColorConverter()
  @JsonKey(name: 'hex_color')
  Color? color;
  final double? position;
  final double? percentDone;
  final User createdBy;
  Duration? repeatAfter;
  final List<Task> subtasks;
  final List<Label> labels;
  final List<TaskAttachment> attachments;
  // TODO: add position(?)

  late final checkboxStatistics = getCheckboxStatistics(description);
  late final hasCheckboxes = checkboxStatistics.total != 0;

  Task({
    this.id = 0,
    this.identifier = '',
    this.title = '',
    this.description = '',
    this.done = false,
    this.reminderDates = const [],
    this.dueDate,
    this.startDate,
    this.endDate,
    this.parentTaskId,
    this.priority,
    this.repeatAfter,
    this.color,
    this.position,
    this.percentDone,
    this.subtasks = const [],
    this.labels = const [],
    this.attachments = const [],
    DateTime? created,
    DateTime? updated,
    required this.createdBy,
    //required this.listId,
    required this.projectId,
    this.bucketId,
  })  : this.created = created ?? DateTime.now(),
        this.updated = updated ?? DateTime.now();

  bool loading = false;

  Color get textColor {
    if (color != null && color!.computeLuminance() > 0.5) {
      return Colors.black;
    }
    return Colors.white;
  }

  bool get hasDueDate => dueDate?.year != 1;
  bool get hasStartDate => startDate?.year != 1;
  bool get hasEndDate => endDate?.year != 1;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  Task copyWith({
    int? id,
    int? parentTaskId,
    int? priority,
    int? listId,
    int? bucketId,
    DateTime? created,
    DateTime? updated,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? endDate,
    List<TaskReminder>? reminderDates,
    String? title,
    String? description,
    String? identifier,
    bool? done,
    Color? color,
    double? position,
    double? percent_done,
    User? createdBy,
    Duration? repeatAfter,
    List<Task>? subtasks,
    List<Label>? labels,
    List<TaskAttachment>? attachments,
  }) {
    return Task(
      id: id ?? this.id,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      priority: priority ?? this.priority,
      //listId: listId ?? this.listId,
      projectId: projectId ?? this.projectId,
      bucketId: bucketId ?? this.bucketId,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminderDates: reminderDates ?? this.reminderDates,
      title: title ?? this.title,
      description: description ?? this.description,
      identifier: identifier ?? this.identifier,
      done: done ?? this.done,
      color: color ?? this.color,
      position: position ?? this.position,
      percentDone: percent_done ?? this.percentDone,
      createdBy: createdBy ?? this.createdBy,
      repeatAfter: repeatAfter ?? this.repeatAfter,
      subtasks: subtasks ?? this.subtasks,
      labels: labels ?? this.labels,
      attachments: attachments ?? this.attachments,
    );
  }
}
