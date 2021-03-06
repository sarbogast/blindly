import 'package:blindly/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'app_config.dart';

void setupBugfender() {
  FlutterBugfender.init(
    "Dqy8fjd7boN0OP7USAjvnUL5lLEiNXQv",
    enableAndroidLogcatLogging: false,
  );
  FlutterBugfender.log('Flutter Bugfender initialized!');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  disableLandscape();
  setupBugfender();
  var configuredApp = AppConfig(
    child: Blindly(),
    appTitle: "[BETA] Blindly",
  );
  return runApp(configuredApp);
}
