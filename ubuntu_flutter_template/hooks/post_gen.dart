import 'dart:convert';
import 'dart:io';
import 'package:mason/mason.dart';

import 'utils.dart';

Future<void> run(HookContext context) async {
  create(context, ProjectDirectory.packages);
  create(context, ProjectDirectory.apps);

  Process.runSync('flutter', ['pub', 'add', '--dev', 'melos']);
  Process.runSync('flutter', ['pub', 'get']);
  Process.runSync('melos', ['bootstrap']);
}

Future<void> create(HookContext context, ProjectDirectory type) async {
  final List<String> projectNames = context.vars[type.listName].cast<String>();
  if (projectNames.isEmpty) {
    return;
  }
  await Process.run('mkdir', [type.name]);

  for (final projectName in projectNames) {
    final progress = context.logger.progress(
      'Creating ${type.templateName} in ${type.name}/$projectName',
    );
    final process = await Process.start(
      'flutter',
      [
        'create',
        '${type.name}/$projectName',
        '-t',
        type.templateName,
        if (type == ProjectDirectory.apps) ...[
          '--platforms=linux',
          '-e',
        ],
      ],
      runInShell: true,
    );
    await process.stderr.transform(utf8.decoder).forEach(print);

    progress.complete();
  }
}
