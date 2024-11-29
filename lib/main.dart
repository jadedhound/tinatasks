import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
    ChangeNotifierProvider<ProjectProvider>(
      create: (_) => ProjectProvider(),
      child: VikunjaGlobal(
        child: VikunjaApp(
          home: HomePage(),
          key: UniqueKey(),
          navKey: globalNavigatorKey,
        ),
        login: VikunjaApp(
          home: LoginPage(),
          key: UniqueKey(),
        ),
      ),
    ),
  );
}

class ThemeModel with ChangeNotifier {
  FlutterThemeMode _themeMode = FlutterThemeMode.dark;
  FlutterThemeMode get themeMode => _themeMode;

  void set themeMode(FlutterThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_themeMode) {
      case FlutterThemeMode.dark:
        return buildVikunjaDarkTheme();
      case FlutterThemeMode.materialYouLight:
        return buildVikunjaMaterialLightTheme();
      case FlutterThemeMode.materialYouDark:
        return buildVikunjaMaterialDarkTheme();
      default:
        return buildVikunjaTheme();
    }
  }

  ThemeData getWithColorScheme(
      ColorScheme? lightTheme, ColorScheme? darkTheme) {
    switch (_themeMode) {
      case FlutterThemeMode.dark:
        return buildVikunjaDarkTheme().copyWith(colorScheme: darkTheme);
      case FlutterThemeMode.materialYouLight:
        return buildVikunjaMaterialLightTheme()
            .copyWith(colorScheme: lightTheme);
      case FlutterThemeMode.materialYouDark:
        return buildVikunjaMaterialDarkTheme().copyWith(colorScheme: darkTheme);
      default:
        return buildVikunjaTheme().copyWith(colorScheme: lightTheme);
    }
  }
}

ThemeModel themeModel = ThemeModel();

class VikunjaApp extends StatelessWidget {
  final Widget home;
  final GlobalKey<NavigatorState>? navKey;
  bool sentryEnabled = false;

  VikunjaApp({Key? key, required this.home, this.navKey}) : super(key: key);

  Future<void> getLaunchData() async {
    try {
      SettingsManager manager = SettingsManager(new FlutterSecureStorage());
      await manager.getThemeMode().then((themeMode) {
        themeModel.themeMode = themeMode;
      });
      sentryEnabled = await manager.getSentryEnabled();
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
                    if (sentryEnabled) {
                      print("sentry enabled");
                      SentryFlutter.init((options) {
                        options.dsn =
                            'https://a09618e3bb30e03b93233c21973df869@o1047380.ingest.us.sentry.io/4507995557134336';
                        options.tracesSampleRate = 1.0;
                        options.profilesSampleRate = 1.0;
                      }).then((_) {
                        FlutterError.onError = (details) async {
                          print("sending to sentry");
                          await Sentry.captureException(
                            details.exception,
                            stackTrace: details.stack,
                          );
                          FlutterError.presentError(details);
                        };
                        PlatformDispatcher.instance.onError = (error, stack) {
                          print("sending to sentry (platform)");
                          Sentry.captureException(error, stackTrace: stack);
                          FlutterError.presentError(FlutterErrorDetails(
                              exception: error, stack: stack));
                          return false;
                        };
                      });

                      return SentryWidget(
                          child: buildMaterialApp(themeModel.getWithColorScheme(
                              lightTheme, darkTheme)));
                    } else {
                      return buildMaterialApp(
                          themeModel.getWithColorScheme(lightTheme, darkTheme));
                    }
                  });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        });
  }

  Widget buildMaterialApp(ThemeData? themeData) {
    return MaterialApp(
      title: 'Vikunja',
      theme: themeData,
      scaffoldMessengerKey: globalSnackbarKey,
      navigatorKey: navKey,
      // <= this
      home: this.home,
    );
  }
}
