fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android bump

```sh
[bundle exec] fastlane android bump
```

Bump version based on current git branch

### android build

```sh
[bundle exec] fastlane android build
```

Build Android APK only (auto-bumps version)

### android build_and_deploy

```sh
[bundle exec] fastlane android build_and_deploy
```

Build and deploy Android app to Firebase App Distribution (auto-bumps version)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
