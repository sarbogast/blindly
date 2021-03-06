import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  final Widget child;
  final bool local;
  final String appTitle;

  AppConfig({
    this.local = false,
    @required this.child,
    @required this.appTitle,
  });

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
