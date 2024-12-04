import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/api/user_implementation.dart';
import 'package:tinatasks/models/user.dart';

class UserLogin extends ChangeNotifier {
  User? _currentUser;
  bool _loading = true;
  bool expired = false;
  late TinaClient _client;

  User? get currentUser => _currentUser;

  TinaClient get client => _client;

  void initState() {
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
}
