import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:permission_handler/permission_handler.dart';
import 'package:tinatasks/global.dart';

import '../main.dart';
import '../models/project.dart';
import '../models/user.dart';
import '../service/services.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  List<Project>? projectList;
  int? defaultProject;
  bool? ignoreCertificates;
  bool? sentryEnabled;
  bool? getVersionNotifications;
  String? versionTag, newestVersionTag;
  late TextEditingController durationTextController;
  bool initialized = false;
  FlutterThemeMode? themeMode;
  User? currentUser;

  void init() {
    durationTextController = TextEditingController();

    VikunjaGlobalWidget.of(context)
        .projectService
        .getAll()
        .then((value) => setState(() => projectList = value));

    VikunjaGlobalWidget.of(context)
        .settingsManager
        .getIgnoreCertificates()
        .then((value) =>
            setState(() => ignoreCertificates = value == "1" ? true : false));

    VikunjaGlobalWidget.of(context)
        .settingsManager
        .getSentryEnabled()
        .then((value) => setState(() => sentryEnabled = value));

    VikunjaGlobalWidget.of(context)
        .settingsManager
        .getVersionNotifications()
        .then((value) => setState(
            () => getVersionNotifications = value == "1" ? true : false));

    VikunjaGlobalWidget.of(context)
        .versionChecker
        .getCurrentVersionTag()
        .then((value) => setState(() => versionTag = value));

    VikunjaGlobalWidget.of(context)
        .settingsManager
        .getWorkmanagerDuration()
        .then((value) => setState(
            () => durationTextController.text = (value.inMinutes.toString())));

    VikunjaGlobalWidget.of(context)
        .settingsManager
        .getThemeMode()
        .then((value) => setState(() => themeMode = value));

    VikunjaGlobalWidget.of(context)
        .newUserService
        ?.getCurrentUser()
        .then((value) => {
              setState(() {
                currentUser = value!;
                defaultProject = value.settings?.defaultProjectId;
              }),
            });

    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final global = VikunjaGlobalWidget.of(context);
    if (!initialized) init();
    return new Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName:
                currentUser != null ? Text(currentUser!.username) : null,
            accountEmail: currentUser != null ? Text(currentUser!.name) : null,
            currentAccountPicture: currentUser == null
                ? null
                : CircleAvatar(
                    backgroundImage: (currentUser?.username != "")
                        ? NetworkImage(currentUser!.avatarUrl(context))
                        : null,
                  ),
          ),
          projectList != null
              ? ListTile(
                  title: Text("Default List"),
                  trailing: DropdownButton<int>(
                    items: [
                      DropdownMenuItem(
                        child: Text("None"),
                        value: null,
                      ),
                      ...projectList!
                          .map((e) => DropdownMenuItem(
                              child: Text(e.title), value: e.id))
                          .toList()
                    ],
                    value: projectList?.firstWhereOrNull(
                                (element) => element.id == defaultProject) !=
                            null
                        ? defaultProject
                        : null,
                    onChanged: (int? value) {
                      setState(() => defaultProject = value);
                      global.newUserService
                          ?.setCurrentUserSettings(currentUser!.settings!
                              .copyWith(default_project_id: value))
                          .then((value) => currentUser!.settings = value);
                      //VikunjaGlobal.of(context).userManager.setDefaultList(value);
                    },
                  ),
                )
              : ListTile(
                  title: Text("..."),
                ),
          Divider(),
          ListTile(
            title: Text("Theme"),
            trailing: DropdownButton<FlutterThemeMode>(
              items: [
                DropdownMenuItem(
                  child: Text("System"),
                  value: FlutterThemeMode.system,
                ),
                DropdownMenuItem(
                  child: Text("Light"),
                  value: FlutterThemeMode.light,
                ),
                DropdownMenuItem(
                  child: Text("Dark"),
                  value: FlutterThemeMode.dark,
                ),
                DropdownMenuItem(
                  child: Text("Material You Light"),
                  value: FlutterThemeMode.materialYouLight,
                ),
                DropdownMenuItem(
                  child: Text("Material You Dark"),
                  value: FlutterThemeMode.materialYouDark,
                ),
              ],
              value: themeMode,
              onChanged: (FlutterThemeMode? value) {
                VikunjaGlobalWidget.of(context)
                    .settingsManager
                    .setThemeMode(value!);
                setState(() => themeMode = value);
                if (themeMode != null) themeModel.themeMode = themeMode!;
              },
            ),
          ),
          Divider(),
          ignoreCertificates != null
              ? CheckboxListTile(
                  title: Text("Ignore Certificates"),
                  value: ignoreCertificates,
                  onChanged: (value) {
                    setState(() => ignoreCertificates = value);
                    VikunjaGlobalWidget.of(context)
                        .client
                        .reloadIgnoreCerts(value);
                  })
              : ListTile(title: Text("...")),
          Divider(),
          sentryEnabled != null
              ? CheckboxListTile(
                  title: Text("Enable Sentry"),
                  subtitle: Text(
                      "Help us debug errors better and faster by sending bug reports to us directly. This is completely anonymous."),
                  value: sentryEnabled,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => sentryEnabled = value);
                    VikunjaGlobalWidget.of(context)
                        .settingsManager
                        .setSentryEnabled(value)
                        .then((_) => themeModel.notify());
                  })
              : ListTile(title: Text("...")),
          Divider(),
          Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(children: [
                Flexible(
                    child: TextField(
                  controller: durationTextController,
                  decoration: InputDecoration(
                    labelText: 'Background Refresh Interval (minutes): ',
                    helperText: 'Minimum: 15, Set limit of 0 for no refresh',
                  ),
                )),
                TextButton(
                    onPressed: () => VikunjaGlobalWidget.of(context)
                        .settingsManager
                        .setWorkmanagerDuration(Duration(
                            minutes: int.parse(durationTextController.text)))
                        .then((value) => VikunjaGlobalWidget.of(context)
                            .updateWorkmanagerDuration()),
                    child: Text("Save")),
              ])),
          Divider(),
          getVersionNotifications != null
              ? CheckboxListTile(
                  title: Text("Get Version Notifications"),
                  value: getVersionNotifications,
                  onChanged: (value) {
                    setState(() => getVersionNotifications = value);
                    if (value != null)
                      VikunjaGlobalWidget.of(context)
                          .settingsManager
                          .setVersionNotifications(value);
                  })
              : ListTile(title: Text("...")),
          TextButton(
              onPressed: () async {
                await Permission.notification.isDenied.then((value) {
                  if (value) {
                    Permission.notification.request();
                  }
                });
                VikunjaGlobalWidget.of(context)
                    .notifications
                    .sendTestNotification();
              },
              child: Text("Send test notification")),
          TextButton(
              onPressed: () => VikunjaGlobalWidget.of(context)
                  .versionChecker
                  .getLatestVersionTag()
                  .run()
                  //TODO: Remove this fallback into something meaningful.
                  .then((value) => setState(() =>
                      newestVersionTag = value.getOrElse(() => "v0.0.0"))),
              child: Text("Check for latest version")),
          Text("Current version: ${versionTag ?? "loading"}"),
          Text(newestVersionTag != null
              ? "Latest version: $newestVersionTag"
              : ""),
          Divider(),
          TextButton(
              onPressed: () =>
                  VikunjaGlobalWidget.of(context).logoutUser(context),
              child: Text("Logout")),
        ],
      ),
    );
  }
}
