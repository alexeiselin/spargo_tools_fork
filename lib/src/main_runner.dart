// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spargo_tools/src/logger.dart';
import 'package:spargo_tools/src/extension/extensions.dart';

/// Класс запуска приложения
mixin MainRunner {
  static void _amendFlutterError() {
    const log = Logger.logFlutterError;

    FlutterError.onError = FlutterError.onError?.amend(log) ?? log;
  }

  static T? _runZoned<T>(T Function() body) => Logger.runLogging(() => runZonedGuarded(body, Logger.logZoneError));

  static void run({required Future<Widget> Function() appBuilder}) {
    _runZoned(
      () async {
        _amendFlutterError();
        runApp(await appBuilder.call());
      },
    );
  }
}
