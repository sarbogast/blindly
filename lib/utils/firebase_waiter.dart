import 'dart:io';

import 'package:blindly/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import '../analytics.dart';
import '../app_config.dart';

class FirebaseWaiter extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final Widget Function(BuildContext) loading;
  final Widget Function(BuildContext, Object) error;

  const FirebaseWaiter({
    @required this.builder,
    @required this.loading,
    @required this.error,
    Key key,
  }) : super(key: key);
  @override
  _FirebaseWaiterState createState() => _FirebaseWaiterState();
}

class _FirebaseWaiterState extends State<FirebaseWaiter> {
  Future<FirebaseApp> firebaseReady;

  @override
  void initState() {
    super.initState();
    firebaseReady = Firebase.initializeApp().then((firebaseApp) {
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user == null) {
          FlutterBugfender.removeDeviceKey("user.phoneNumber");
          analytics.setUserId(null);
        } else {
          FlutterBugfender.setDeviceString(
            "user.phoneNumber",
            user.phoneNumber,
          );
        }
      });

      bool localEnvironment = AppConfig.of(context).local;
      if (localEnvironment) {
        String host = (!kIsWeb && Platform.isAndroid)
            ? '10.0.2.2:8080'
            : 'localhost:8080';

        FirebaseFirestore.instance.settings = Settings(
          host: host,
          sslEnabled: false,
          persistenceEnabled: false,
        );
      }

      return firebaseApp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: firebaseReady,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log.e(snapshot.error.toString(), snapshot.error);
          return widget.error(context, snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;
          return widget.builder(context);
        }
        return widget.loading(context);
      },
    );
  }
}
