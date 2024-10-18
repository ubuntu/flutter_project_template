# Flutter project template

This project is an opinionated starting point for a Flutter application.

In this project we are using the following tools to set up a solid structure for a Flutter project:

1. [FVM](https://fvm.app) for managing Flutter SDK versions.
2. [Melos](https://melos.invertase.dev) for handling mono-repos.
3. [Riverpod](https://riverpod.dev) for state management.
4. [renovate](https://docs.renovatebot.com/) for keeping dependencies up to date.
5. [ubuntu_lints](https://pub.dev/packages/ubuntu_lints) for linting.
6. [GitHub actions](https://github.com/features/actions) for CI/CD.

## Preparations

Before you start working on the project, make sure you have the following tools installed:

### FVM

FVM is a simple version manager for Flutter. It allows you to have multiple Flutter versions installed and switch
between them with ease, which is useful when working on multiple projects that require different Flutter versions.

Install [fvm](https://fvm.app) globally by following the instructions [here](https://fvm.app/docs/getting_started/installation).

You will also need to change your IDE settings to use the Flutter SDK installed by FVM. In Android Studio/Intellij you
can do this by going to `File > Project Structure > Project` and selecting the Flutter SDK installed by FVM in the
`.fvm` directory in your project, and similarly you can do this in VS Code by  pressing `Ctrl + Shift + P` and selecting
`Flutter: Change SDK`.


### Melos

Melos is a tool for managing Dart and Flutter mono-repos. It allows you to manage multiple packages and apps in a single
repository. This is useful when you have multiple packages that depend on each other, as it allows you to manage them
all in one place. It also allows for running commands across all packages in the mono-repo, versioning them together,
generating changelogs, and more.

Install [Melos](https://melos.invertase.dev) globally by running:

```bash
flutter pub global activate melos
```

In the GitHub Actions workflow, we are using the [melos-action](https://github.com/marketplace/actions/melos-action) to
install Melos, run Melos commands and automatically version and publish packages (if they are non-private).

## Getting started

After you have created a new project on GitHub you can use Mason to get started with this template.
[Mason](https://docs.brickhub.dev) is a CLI tool that allows you to create new projects from templates.

You can install it by running:

```bash
flutter pub global activate mason-cli
```

Then you can install the template by running:

```bash
mason add -g ubuntu_flutter_template
```

And to create a new project from the template run:

```bash
mason make ubuntu_flutter_template
```

## Architecture and state management

For state management we use Riverpod with an MVVM (Model-View-ViewModel) style architecture.

 - Models: Plain immutable Dart classes that represent the data in the app.
 - ViewModels: Classes that contain the business logic of the app. They are responsible for fetching data, transforming
   it, and exposing it to the UI. When using Riverpod the ViewModel is either the `notifier` or the `provider` itself.
 - Views: Widgets that are responsible for rendering the page. They should not contain any business logic.







TODO:
- Show what needs to be set up in pub and on GitHub
- Possibly use Mason (https://pub.dev/packages/mason)
- Linting
- License