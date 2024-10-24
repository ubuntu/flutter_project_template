import 'dart:async';

import 'package:mason/mason.dart';

enum ProjectDirectory {
  packages('package', 'packageNames'),
  apps('app', 'appNames');

  const ProjectDirectory(
    this.templateName, // The name of the Flutter template to use.
    this.listName, // The name of the list of project names in the context.
  );

  final String templateName;
  final String listName;
}

extension LoggerExtension on Logger {
  void logAndCompleteBasedOnMarkers(
    String message,
    String successMarker,
    String failureMarker,
    Completer<void>? completer, {
    required bool isSilent,
    bool isError = false,
  }) {
    final modifiedMessage = _processMessageBasedOnMarkers(
      message,
      successMarker,
      failureMarker,
      completer,
    );
    if (isError) {
      err(modifiedMessage);
    } else if (!isSilent) {
      info(modifiedMessage);
    }
  }

  String _processMessageBasedOnMarkers(
    String message,
    String successMarker,
    String failureMarker,
    Completer<void>? completer,
  ) {
    if (message.contains(successMarker)) {
      completer?.complete();
      return message.replaceAll(successMarker, '');
    }

    if (message.contains(failureMarker)) {
      completer?.complete();
      return message.replaceAll(failureMarker, '');
    }

    return message;
  }
}
