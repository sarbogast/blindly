import 'package:blindly/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'app_config.dart';

void setupBugfender() {
  FlutterBugfender.init(
    "e04zgDtwEzXzggiAyjYadDclZEIyYf18",
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
    appTitle: "Blindly",
  );
  return runApp(configuredApp);
}
