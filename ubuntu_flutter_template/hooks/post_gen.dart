import 'dart:convert';
import 'dart:io';
import 'package:mason/mason.dart';

import 'utils.dart';

Future<void> run(HookContext context) async {
  create(context, ProjectDirectory.packages);
  create(context, ProjectDirectory.apps);

  final process = await Process.start(
    'melos',
    ['bootstrap'],
    runInShell: true,
  );
  await process.stderr.transform(utf8.decoder).forEach(print);
}

Future<void> create(HookContext context, ProjectDirectory type) async {
  final List<String> projectNames = context.vars[type.listName].cast<String>();
  if (projectNames.isEmpty) {
    return;
  }
  await Process.run('mkdir', [type.name]);

  for (final projectName in projectNames) {
    final progress =
        context.logger.progress('Creating ${type.templateName} $projectName');
    final process = await Process.start(
      'flutter',
      [
        'create',
        '${type.name}/$projectName',
        '-t',
        type.templateName,
        if (type == ProjectDirectory.apps) '--platforms=linux',
      ],
      runInShell: true,
    );
    await process.stderr.transform(utf8.decoder).forEach(print);

    progress.complete();
  }
}
