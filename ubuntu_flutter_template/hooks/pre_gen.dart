import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:pub_api_client/pub_api_client.dart';

import 'utils.dart';

Future<void> run(HookContext context) async {
  final directory = Directory.current;
  final directoryName = path.basename(directory.path);
  final userDefinedWorkspaceName = context.vars['workspaceName'] as String;
  final name = userDefinedWorkspaceName.isNotEmpty
      ? userDefinedWorkspaceName
      : directoryName;
  context.vars['workspaceName'] = name;

  if (directory.listSync().isNotEmpty) {
    // TODO: Print pwd
    context.logger.warn('The current directory is not empty.');
    final shouldContinue = context.logger.confirm('Do you want to continue?');
    if (!shouldContinue) {
      exit(1);
    }
  }

  maybeInstallMelos(context);
  maybeInstallFvm(context);

  final List<String> appNames = context.vars[ProjectDirectory.apps.listName]
      .cast<String>()
      .map((s) => s.trim());
  final List<String> projectNames = context
      .vars[ProjectDirectory.packages.listName]
      .cast<String>()
      .map((s) => s.trim());
  context.vars['containsApps'] = appNames.isNotEmpty;
  context.vars['containsPackages'] = projectNames.isNotEmpty;

  context.vars['flutterVersion'] = _getVersion(_Program.flutter);
  context.vars['sdkVersion'] = _getVersion(_Program.dart);

  final pubClient = PubClient();
  final lintsVersion = (await pubClient.packageVersions('ubuntu_lints')).first;
  context.vars['lintsVersion'] = lintsVersion;
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
