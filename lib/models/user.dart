import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tinatasks/global.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserSettings {
  final int defaultProjectId;
  final bool discoverableByEmail, discoverableByName, emailRemindersEnabled;
  final Map<String, dynamic>? frontendSettings;
  final String language;
  final String name;
  final bool overdueTasksRemindersEnabled;
  final String overdueTasksRemindersTime;
  final String timezone;
  final int weekStart;

  UserSettings({
    this.defaultProjectId = 0,
    this.discoverableByEmail = false,
    this.discoverableByName = false,
    this.emailRemindersEnabled = false,
    this.frontendSettings = null,
    this.language = '',
    this.name = '',
    this.overdueTasksRemindersEnabled = false,
    this.overdueTasksRemindersTime = '',
    this.timezone = '',
    this.weekStart = 0,
  });

  UserSettings copyWith({
    int? default_project_id,
    bool? discoverable_by_email,
    bool? discoverable_by_name,
    bool? email_reminders_enabled,
    Map<String, dynamic>? frontend_settings,
    String? language,
    String? name,
    bool? overdue_tasks_reminders_enabled,
    String? overdue_tasks_reminders_time,
    String? timezone,
    int? week_start,
  }) {
    return UserSettings(
      defaultProjectId: default_project_id ?? this.defaultProjectId,
      discoverableByEmail: discoverable_by_email ?? this.discoverableByEmail,
      discoverableByName: discoverable_by_name ?? this.discoverableByName,
      emailRemindersEnabled:
          email_reminders_enabled ?? this.emailRemindersEnabled,
      frontendSettings: frontend_settings ?? this.frontendSettings,
      language: language ?? this.language,
      name: name ?? this.name,
      overdueTasksRemindersEnabled:
          overdue_tasks_reminders_enabled ?? this.overdueTasksRemindersEnabled,
      overdueTasksRemindersTime:
          overdue_tasks_reminders_time ?? this.overdueTasksRemindersTime,
      timezone: timezone ?? this.timezone,
      weekStart: week_start ?? this.weekStart,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final int id;
  final String name, username;
  final DateTime created, updated;
  UserSettings? settings;

  User({
    this.id = 0,
    this.name = '',
    required this.username,
    DateTime? created,
    DateTime? updated,
    this.settings,
  })  : this.created = created ?? DateTime.now(),
        this.updated = updated ?? DateTime.now();

  String avatarUrl(BuildContext context) {
    return VikunjaGlobalWidget.of(context).client.base +
        "/avatar/${this.username}";
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

class UserTokenPair {
  final User? user;
  final String? token;
  final int error;
  final String errorString;
  UserTokenPair(this.user, this.token, {this.error = 0, this.errorString = ""});
}

class BaseTokenPair {
  final String base;
  final String token;
  BaseTokenPair(this.base, this.token);
}
