import 'package:blindly/app_config.dart';
import 'package:blindly/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme.dart';

// At this stage, Firebase has been initialized
class BlindlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.of(context).appTitle,
      theme: blindlyTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OnboardingScreen(),
    );
  }
}
