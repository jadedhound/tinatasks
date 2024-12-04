import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/task_implementation.dart';
import 'package:tinatasks/api/user_implementation.dart';
import 'package:tinatasks/managers/notifications.dart';
import 'package:tinatasks/service/services.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    if (task == "update-tasks" && inputData != null) {
      TinaClient client = TinaClient(
          token: inputData["client_token"],
          base: inputData["client_base"],
          authenticated: true);
      tz.initializeTimeZones();

      return SettingsManager(new FlutterSecureStorage())
          .getIgnoreCertificates()
          .then((value) async {
        print("ignoring: $value");
        client.reloadIgnoreCerts(value == "1");

        TaskAPIService taskService = TaskAPIService(client);
        NotificationClass nc = NotificationClass();
        await nc.notificationInitializer();
        return nc
            .scheduleDueNotifications(taskService)
            .then((value) => Future.value(true));
      });
    } else if (task == "refresh-token") {
      print("running refresh from workmanager");
      final FlutterSecureStorage _storage = new FlutterSecureStorage();

      var currentUser = await _storage.read(key: 'currentUser');
      if (currentUser == null) {
        return Future.value(true);
      }
      var token = await _storage.read(key: currentUser);

      var base = await _storage.read(key: '${currentUser}_base');
      if (token == null || base == null) {
        return Future.value(true);
      }
      TinaClient client = TinaClient();
      client.configure(token: token, base: base, authenticated: true);
      // load new token from server to avoid expiration
      String? newToken = await UserAPIService(client).getToken();
      if (newToken != null) {
        _storage.write(key: currentUser, value: newToken);
      }
      return Future.value(true);
    } else {
      return Future.value(true);
    }
  });
}
