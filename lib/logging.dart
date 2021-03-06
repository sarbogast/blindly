import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:logger/logger.dart';

final log = Logger(output: ConsoleAndBugfenderOutput());

class ConsoleAndBugfenderOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      print(line);
    }
    switch (event.level) {
      case Level.debug:
        event.lines.forEach((line) => FlutterBugfender.debug(line));
        break;
      case Level.verbose:
        event.lines.forEach((line) => FlutterBugfender.trace(line));
        break;
      case Level.info:
        event.lines.forEach((line) => FlutterBugfender.info(line));
        break;
      case Level.warning:
        event.lines.forEach((line) => FlutterBugfender.warn(line));
        break;
      case Level.error:
        event.lines.forEach((line) => FlutterBugfender.error(line));
        break;
      case Level.wtf:
        event.lines.forEach((line) => FlutterBugfender.fatal(line));
        break;
      case Level.nothing:
        event.lines.forEach((line) => FlutterBugfender.log(line));
        break;
    }
  }
}
