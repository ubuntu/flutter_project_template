import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

import 'utils.dart';

void run(HookContext context) {
  final directory = Directory.current;
  final directoryName = path.basename(directory.path);
  final name = context.vars['workspace_name'] ?? directoryName;
  context.vars['workspace_name'] = name;

  final contents =
      directory.listSync().where((e) => !e.path.endsWith('.mason'));
  print(contents);

  if (contents.isNotEmpty) {
    context.logger.warn('The current directory is not empty.');
    final shouldContinue = context.logger.confirm('Do you want to continue?');
    if (!shouldContinue) {
      exit(1);
    }
  }

  maybeInstallMelos(context);
  maybeInstallFvm(context);

  final List<String> appNames =
      context.vars[ProjectDirectory.packages.listName].cast<String>();
  final List<String> projectNames =
      context.vars[ProjectDirectory.packages.listName].cast<String>();
  context.vars['contains_apps'] = appNames.isNotEmpty;
  context.vars['contains_packages'] = projectNames.isNotEmpty;

  context.vars['flutter_version'] = _getVersion(_Program.flutter);
  context.vars['sdk_version'] = _getVersion(_Program.dart);

  Process.runSync('flutter', ['pub', 'add', 'melos']);
}

String _getVersion(_Program program) {
  final result = Process.runSync(program.name, ['--version']);
  final name = program.name.capitalize();
  if (result.exitCode == 0) {
    final output = result.stdout as String;
    final versionLine =
        output.split('\n').firstWhere((line) => line.contains(name));
    final version = versionLine.split(' ')[program.versionIndex];
    return version;
  } else {
    throw Exception('Failed to get $name version: ${result.stderr}');
  }
}

bool programExists(String binaryName) {
  final result = Process.runSync('which', [binaryName]);
  return result.exitCode == 0;
}

void maybeInstallMelos(HookContext context) {
  if (!programExists('melos')) {
    final shouldInstall = context.logger.confirm(
      'Melos is not installed. Do you want to install it?',
    );
    if (shouldInstall) {
      final result = Process.runSync('flutter', [
        'pub',
        'global',
        'install',
        'melos',
      ]);
      if (result.exitCode != 0) {
        throw Exception('Failed to install Melos: ${result.stderr}');
      }
    }
  }
}

void maybeInstallFvm(HookContext context) {
  if (!programExists('fvm')) {
    final shouldInstall = context.logger.confirm(
      'FVM is not installed. Do you want to install it?',
    );
    if (shouldInstall) {
      final result = Process.runSync('curl', [
        '-fsSL' 'https://fvm.app/install.sh' '| bash',
      ]);
      if (result.exitCode != 0) {
        throw Exception('Failed to install FVM: ${result.stderr}');
      }
    }
  }
}

enum _Program {
  flutter(1),
  dart(3);

  const _Program(this.versionIndex);

  final int versionIndex;
}

extension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + this.substring(1);
  }
}
