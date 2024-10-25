import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';

import 'utils.dart';

final failedLabel = 'FAILED';

class PersistentShell {
  PersistentShell({
    required this.logger,
    this.silent = true,
    this.workingDirectory,
  });

  final bool silent;
  final Logger logger;
  final String? workingDirectory;
  late final Process _process;
  Completer<void>? _commandCompleter;
  final String _successEndMarker = '__SUCCESS_COMMAND_END__';
  final String _failureEndMarker = '__FAILURE_COMMAND_END__';

  Future<void> startShell() async {
    _process = await Process.start(
      '/bin/sh',
      [],
      workingDirectory: workingDirectory,
    );

    _listenToProcessStream(_process.stdout, isSilent: silent);
    _listenToProcessStream(_process.stderr, isError: true, isSilent: silent);
  }

  Future<bool> sendCommand(String command) async {
    assert(_commandCompleter == null, 'A command is already in progress.');
    _commandCompleter = Completer<void>();

    final fullCommand = _buildFullCommand(command);
    _process.stdin.writeln(fullCommand);

    return _awaitCommandCompletion();
  }

  Future<void> stopShell() async {
    await _process.stdin.close();
    final exitCode = await _process.exitCode;
    if (exitCode != 0) {
      logger.err(failedLabel);
    }
  }

  Future<bool> _awaitCommandCompletion() async {
    try {
      await _commandCompleter!.future;
      return true;
    } catch (e) {
      return false;
    } finally {
      _commandCompleter = null;
    }
  }

  void _listenToProcessStream(
    Stream<List<int>> stream, {
    bool isError = false,
    required bool isSilent,
  }) {
    stream.listen((event) {
      final output = utf8.decode(event, allowMalformed: true);
      logger.logAndCompleteBasedOnMarkers(
        output,
        _successEndMarker,
        _failureEndMarker,
        _commandCompleter,
        isError: isError,
        isSilent: isSilent,
      );
    });
  }

  String _buildFullCommand(String command) {
    final echoSuccess = 'echo $_successEndMarker';
    final echoFailure = 'echo $_failureEndMarker';

    return '''
   $command || true && if [ \$? -ne 0 ]; 
    then $echoFailure; else $echoSuccess; fi
  ''';
  }
}
