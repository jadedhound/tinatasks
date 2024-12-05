import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionChecker {
  GlobalKey<ScaffoldMessengerState> snackbarKey;
  VersionChecker(this.snackbarKey);
  final log = Logger('VersionChecker');

  String repo = "https://github.com/go-vikunja/app/releases/latest";

  TaskOption<String> getLatestVersionTag() {
    String api = "https://api.github.com/repos/go-vikunja/app";
    String endpoint = "/releases";

    return TaskOption.tryCatch(() async => get(Uri.parse(api + endpoint)).then(
          (response) {
            dynamic jsonResponse = json.decode(response.body);
            String latestVersion = jsonResponse[0]['tag_name'];
            if (latestVersion.startsWith("v")) {
              latestVersion = latestVersion.replaceFirst("v", "");
            }
            return latestVersion;
          },
        ));
  }

  Future<String> getCurrentVersionTag() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print("current: " + packageInfo.version);
    return packageInfo.version;
  }

  postVersionCheckSnackbar() async {
    final current = getCurrentVersionTag();
    final latest = await getLatestVersionTag().run();
    latest.match(
      () => log.warning("Unable to fetch latest version tag"),
      (latest) {
        if (current != latest) {
          SnackBar snackBar = SnackBar(
            content: Text("New version available: $latest"),
            action: SnackBarAction(
                label: "View on Github",
                onPressed: () => launchUrl(Uri.parse(repo),
                    mode: LaunchMode.externalApplication)),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
      },
    );
  }
}
