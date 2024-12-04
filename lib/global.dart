import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tinatasks/api/bucket_implementation.dart';
import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/label_task.dart';
import 'package:tinatasks/api/label_task_bulk.dart';
import 'package:tinatasks/api/labels.dart';
import 'package:tinatasks/api/server_implementation.dart';
import 'package:tinatasks/api/task_implementation.dart';
import 'package:tinatasks/api/user_implementation.dart';
import 'package:tinatasks/api/version_check.dart';
import 'package:tinatasks/managers/notifications.dart';
import 'package:tinatasks/managers/user.dart';
import 'package:tinatasks/models/user.dart';
import 'package:tinatasks/service/services.dart';
import 'package:workmanager/workmanager.dart';

import 'api/project.dart';
import 'api/view.dart';

final globalSnackbarKey = GlobalKey<ScaffoldMessengerState>();
final globalNavigatorKey = GlobalKey<NavigatorState>();

class VikunjaGlobalWidget extends StatefulWidget {
  final Widget child;
  final Widget login;

  VikunjaGlobalWidget({required this.child, required this.login});

  @override
  VikunjaGlobalWidgetState createState() => VikunjaGlobalWidgetState();

  static VikunjaGlobalWidgetState of(BuildContext context) {
    var widget =
        context.dependOnInheritedWidgetOfExactType<VikunjaGlobalInherited>();
    return widget!.data;
  }
}

class VikunjaGlobalWidgetState extends State<VikunjaGlobalWidget> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  User? _currentUser;
  bool _loading = true;
  bool expired = false;
  late TinaClient _client;
  UserService? _newUserService;
  NotificationClass _notificationClass = NotificationClass();

  User? get currentUser => _currentUser;

  TinaClient get client => _client;

  GlobalKey<ScaffoldMessengerState> get snackbarKey => globalSnackbarKey;

  UserManager get userManager => new UserManager(_storage);

  UserService? get newUserService => _newUserService;

  ServerService get serverService => new ServerAPIService(client);

  SettingsManager get settingsManager => new SettingsManager(_storage);

  VersionChecker get versionChecker => new VersionChecker(snackbarKey);

  ProjectService get projectService => new ProjectAPIService(client, _storage);

  ProjectViewService get projectViewService =>
      new ProjectViewAPIService(client);

  TaskService get taskService => new TaskAPIService(client);

  BucketService get bucketService => new BucketAPIService(client);

  TaskServiceOptions get taskServiceOptions => new TaskServiceOptions();

  NotificationClass get notifications => _notificationClass;

  LabelService get labelService => new LabelAPIService(client);

  LabelTaskService get labelTaskService => new LabelTaskAPIService(client);

  LabelTaskBulkAPIService get labelTaskBulkService =>
      new LabelTaskBulkAPIService(client);

  late String currentTimeZone;

  void updateWorkmanagerDuration() {
    Workmanager().cancelAll().then((value) {
      settingsManager.getWorkmanagerDuration().then((duration) {
        if (duration.inMinutes > 0) {
          Workmanager().registerPeriodicTask("update-tasks", "update-tasks",
              frequency: duration,
              constraints: Constraints(
                  networkType: NetworkType.connected, requiresDeviceIdle: true),
              initialDelay: Duration(seconds: 15),
              inputData: {
                "client_token": client.token,
                "client_base": client.base
              });
        }

        Workmanager().registerPeriodicTask("refresh-token", "refresh-token",
            frequency: Duration(hours: 12),
            constraints: Constraints(
                networkType: NetworkType.connected, requiresDeviceIdle: true),
            initialDelay: Duration(seconds: 15));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _client = TinaClient();
    settingsManager
        .getIgnoreCertificates()
        .then((value) => client.reloadIgnoreCerts(value == "1"));
    _newUserService = UserAPIService(client);
    _loadCurrentUser();
    tz.initializeTimeZones();
    notifications.notificationInitializer();
    settingsManager.getVersionNotifications().then((value) {
      if (value == "1") {
        versionChecker.postVersionCheckSnackbar();
      }
    });
  }

  void changeUser(User newUser, {String? token, String? base}) async {
    setState(() {
      _loading = true;
    });

    if (token == null) {
      token = await _storage.read(key: newUser.id.toString());
    } else {
      // Write new token to secure storage
      await _storage.write(key: newUser.id.toString(), value: token);
    }
    if (base == null) {
      base = await _storage.read(key: "${newUser.id.toString()}_base");
    } else {
      // Write new base to secure storage
      await _storage.write(key: "${newUser.id.toString()}_base", value: base);
    }
    // Set current user in storage
    await _storage.write(key: 'currentUser', value: newUser.id.toString());
    client.configure(token: token, base: base, authenticated: true);
    updateWorkmanagerDuration();

    setState(() {
      _currentUser = newUser;
      _loading = false;
    });
  }

  void logoutUser(BuildContext context) async {
    final userId = await _storage.read(key: "currentUser");
    await _storage.delete(key: userId!); //delete token
    await _storage.delete(key: "${userId}_base");
    setState(() {
      client.reset();
      _currentUser = null;
    });
  }

  void _loadCurrentUser() async {
    var currentUser = await _storage.read(key: 'currentUser');
    if (currentUser == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    var token = await _storage.read(key: currentUser);
    var base = await _storage.read(key: '${currentUser}_base');
    if (token == null || base == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    client.configure(token: token, base: base, authenticated: true);
    User loadedCurrentUser;
    try {
      loadedCurrentUser = await UserAPIService(client).getCurrentUser();
      // load new token from server to avoid expiration
      String? newToken = await newUserService?.getToken();
      _storage.write(key: currentUser, value: newToken);
      client.configure(token: newToken);
    } on ApiException catch (e) {
      dev.log("Error code: " + e.errorCode.toString(), level: 1000);
      if (e.errorCode ~/ 100 == 4) {
        client.authenticated = false;
        if (e.errorCode == 401) {
          // token has expired, but we can reuse username and base. user just has to enter password again
          expired = true;
        }
        setState(() {
          client.authenticated = false;
          _currentUser = null;
          _loading = false;
        });
        return;
      }
      loadedCurrentUser = User(id: int.parse(currentUser), username: '');
    } catch (otherExceptions) {
      loadedCurrentUser = User(id: int.parse(currentUser), username: '');
    }
    updateWorkmanagerDuration();
    setState(() {
      _currentUser = loadedCurrentUser;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new Center(child: new CircularProgressIndicator());
    }
    if (client.authenticated) {
      notifications.scheduleDueNotifications(taskService);
    }
    return new VikunjaGlobalInherited(
      data: this,
      key: UniqueKey(),
      child: !client.authenticated ? widget.login : widget.child,
    );
  }
}

class VikunjaGlobalInherited extends InheritedWidget {
  final VikunjaGlobalWidgetState data;

  VikunjaGlobalInherited({Key? key, required this.data, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(VikunjaGlobalInherited oldWidget) {
    return (data.currentUser != null &&
            data.currentUser!.id != oldWidget.data.currentUser!.id) ||
        data.client != oldWidget.data.client;
  }
}
