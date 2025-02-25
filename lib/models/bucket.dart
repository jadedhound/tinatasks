import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/models/task.dart';
import 'package:tinatasks/models/user.dart';

part 'bucket.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Bucket {
  int id, limit;
  int? projectViewId;
  String title;
  double? position;
  final DateTime created, updated;
  User createdBy;
  final List<Task> tasks;

  Bucket({
    this.id = 0,
    required this.projectViewId,
    required this.title,
    this.position,
    required this.limit,
    DateTime? created,
    DateTime? updated,
    required this.createdBy,
    List<Task>? tasks,
  })  : this.created = created ?? DateTime.now(),
        this.updated = created ?? DateTime.now(),
        this.tasks = tasks ?? [];

  factory Bucket.fromJson(Map<String, dynamic> json) => _$BucketFromJson(json);
  Map<String, dynamic> toJson() => _$BucketToJson(this);
}
