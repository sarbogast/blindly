import 'package:blindly/app_config.dart';
import 'package:blindly/utils/firebase_waiter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'blindly_app.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void disableLandscape() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class Blindly extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseWaiter(
      error: (context, error) => ErrorApp(),
      loading: (context) => MaterialApp(
        title: AppConfig.of(context).appTitle,
        theme: blindlyTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(),
      ),
      builder: (context) => BlindlyApp(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.of(context).appTitle,
      theme: blindlyTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).firebaseInitializationError),
        ),
      ),
    );
  }
}
