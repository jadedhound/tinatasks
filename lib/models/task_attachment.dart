import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/models/user.dart';

part 'task_attachment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskAttachmentFile {
  final int id;
  final DateTime created;
  final String mime;
  final String name;
  final int size;

  TaskAttachmentFile({
    required this.id,
    required this.created,
    required this.mime,
    required this.name,
    required this.size,
  });

  factory TaskAttachmentFile.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentFileFromJson(json);
  Map<String, dynamic> toJson() => _$TaskAttachmentFileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskAttachment {
  final int id, taskId;
  final DateTime created;
  final User createdBy;
  final TaskAttachmentFile file;
  // TODO: add file

  TaskAttachment({
    this.id = 0,
    required this.taskId,
    DateTime? created,
    required this.createdBy,
    required this.file,
  }) : this.created = created ?? DateTime.now();

  factory TaskAttachment.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$TaskAttachmentToJson(this);
}
