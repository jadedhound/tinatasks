import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tinatasks/global.dart';
import 'package:tinatasks/pages/home.dart';
import 'package:tinatasks/pages/user/login.dart';
import 'package:tinatasks/service/services.dart';
import 'package:tinatasks/service/workmanager.dart';
import 'package:tinatasks/stores/project_store.dart';
import 'package:tinatasks/theme/theme.dart';
import 'package:workmanager/workmanager.dart';

final globalSnackbarKey = GlobalKey<ScaffoldMessengerState>();
final globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Required to start background services before the app is run by runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  runApp(
    VikunjaGlobal(
      child: ChangeNotifierProvider<ProjectProvider>(
        create: (_) => ProjectProvider(),
        child: VikunjaApp(
          home: HomePage(),
          key: UniqueKey(),
          navKey: globalNavigatorKey,
        ),
      ),
      login: VikunjaApp(
        home: LoginPage(),
        key: UniqueKey(),
      ),
    ),
  );
}

ThemeModel themeModel = ThemeModel();

class VikunjaApp extends StatelessWidget {
  final Widget home;
  final GlobalKey<NavigatorState>? navKey;

  VikunjaApp({Key? key, required this.home, this.navKey}) : super(key: key);

  Future<void> getLaunchData() async {
    try {
      SettingsManager manager = SettingsManager(FlutterSecureStorage());
      await manager.getThemeMode().then((themeMode) {
        themeModel.themeMode = themeMode;
      });
    } catch (e) {
      print("Failed to get theme mode: $e");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return new ListenableBuilder(
        listenable: themeModel,
        builder: (_, mode) {
          return FutureBuilder<void>(
              future: getLaunchData(),
              builder: (BuildContext context, data) {
                if (data.hasData) {
                  return new DynamicColorBuilder(
                      builder: (lightTheme, darkTheme) {
                    return buildMaterialApp(
                        themeModel.getWithColorScheme(lightTheme, darkTheme));
                  });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        });
  }

  Widget buildMaterialApp(ThemeData? themeData) {
    return MaterialApp(
      title: 'TinaTasks',
      theme: themeData,
      scaffoldMessengerKey: globalSnackbarKey,
      navigatorKey: navKey,
      home: this.home,
    );
  }
}
