import 'dart:convert';
import 'dart:io';
import 'package:mason/mason.dart';

import 'persistent_shell.dart';
import 'utils.dart';

const dependencies = {
  'apps': ['ubuntu_lints', 'flutter_riverpod'],
  'packages': ['ubuntu_lints'],
};

Future<void> run(HookContext context) async {
  await create(context, ProjectDirectory.packages);
  await create(context, ProjectDirectory.apps);

  // TODO: Change to unversioned (latest)
  Process.runSync('flutter', ['pub', 'add', '--dev', 'melos:6.1.0']);
  Process.runSync('flutter', ['pub', 'get']);

  _runSync(context, 'fvm', ['install']);
  _runSync(context, 'melos', ['bootstrap'], silent: true);
}

Future<void> create(HookContext context, ProjectDirectory type) async {
  final List<String> projectNames = context.vars[type.listName].cast<String>();
  if (projectNames.isEmpty) {
    return;
  }
  await Process.run('mkdir', [type.name]);

  for (final projectName in projectNames) {
    final projectDirectory = '${type.name}/$projectName';

    final progress = context.logger.progress(
      'Creating ${type.templateName} in ${type.name}/$projectName',
    );

    final shell = PersistentShell(logger: context.logger);
    await shell.startShell();
    await shell.sendCommand(
      [
        'flutter',
        'create',
        projectDirectory,
        '-t',
        type.templateName,
        if (type == ProjectDirectory.apps) ...[
          '--platforms=linux',
          '-e',
        ],
      ].join(' '),
    );
    await shell.sendCommand('cd $projectDirectory');
    await shell.sendCommand(
      ['flutter', 'pub', 'remove', 'flutter_lints'].join(' '),
    );

    for (final dependency in dependencies[type.name]!) {
      await shell.sendCommand(
        ['flutter', 'pub', 'add', dependency].join(' '),
      );
    }

    await shell.sendCommand(
      'echo "include: package:ubuntu_lints/analysis_options.yaml" > analysis_options.yaml',
    );

    await shell.stopShell();
    progress.complete();
  }
}

void _runSync(
  HookContext context,
  String executable,
  List<String> arguments, {
  bool silent = false,
}) {
  final result = Process.runSync(
    executable,
    arguments,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (!silent) {
    context.logger.info(result.stdout);
  }
  context.logger.err(result.stderr);
}
