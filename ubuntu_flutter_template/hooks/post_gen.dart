import 'dart:convert';
import 'dart:io';
import 'package:mason/mason.dart';

import 'persistent_shell.dart';
import 'utils.dart';

const dependencies = {
  'apps': ['ubuntu_lints', 'flutter_riverpod', 'yaru'],
  'packages': ['ubuntu_lints'],
};

Future<void> run(HookContext context) async {
  await create(context, ProjectDirectory.packages);
  await create(context, ProjectDirectory.apps);

  Process.runSync('flutter', ['pub', 'add', 'melos']);
  Process.runSync('flutter', ['pub', 'get']);

  _runSync(context, 'fvm', ['install']);
  _runSync(context, 'melos', ['bootstrap'], silent: true);
  context.logger.info('Workspace setup complete!');
}

Future<void> create(HookContext context, ProjectDirectory type) async {
  final List<String> projectNames = _parseStringList(context, type.listName);
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

List<String> _parseStringList(HookContext context, String key) {
  return context.vars[key]
      .cast<String>()
      .map((s) => s.trim())
      .toList()
      .cast<String>();
}
