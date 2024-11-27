import 'package:tinatasks/models/label.dart';
import 'package:tinatasks/models/task.dart';
import 'package:tinatasks/models/user.dart';

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
