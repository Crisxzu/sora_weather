#!/bin/zsh

dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n