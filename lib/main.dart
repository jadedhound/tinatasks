import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:tinatasks/global.dart';
import 'package:tinatasks/pages/home.dart';
import 'package:tinatasks/pages/user/login.dart';
import 'package:tinatasks/service/services.dart';
import 'package:tinatasks/service/workmanager.dart';
import 'package:tinatasks/stores/project_store.dart';
import 'package:tinatasks/theme/theme.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  if (kDebugMode) {
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      final time = "${record.time.hour}:${record.time.second}";
      print(
          '${record.level.name} (${record.loggerName} | $time): ${record.message}');
    });
  }
  // Required to start background services before the app is run by runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => GlobalState())
      ],
      child: VikunjaGlobalWidget(
        child: Consumer<GlobalState>(
          builder: (_, state, __) => state.client.authenticated
              ? VikunjaApp(page: HomePage(), navKey: globalNavigatorKey)
              : VikunjaApp(page: LoginPage()),
        ),
      ),
    ),
  );
}

ThemeModel themeModel = ThemeModel();

class VikunjaApp extends StatelessWidget {
  final Widget page;
  final GlobalKey<NavigatorState>? navKey;

  VikunjaApp({required this.page, this.navKey}) : super(key: UniqueKey());

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
      home: this.page,
    );
  }
}
