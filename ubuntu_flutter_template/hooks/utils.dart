enum ProjectDirectory {
  packages('package', 'package_names'),
  apps('app', 'app_names');

  const ProjectDirectory(
    this.templateName, // The name of the Flutter template to use.
    this.listName, // The name of the list of project names in the context.
  );

  final String templateName;
  final String listName;
}
