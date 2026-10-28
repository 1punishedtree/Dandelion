# Dandelion

A native SwiftUI password generator for iOS and macOS. The app display name is `random`.

## Features

- **Options tab**: choose character sets (uppercase, lowercase, numbers, symbols), adjust password length and count with stepper (+/-) controls.
- **Presets**: Standard / Readable / Strong.
- **Passwords**: tap the refresh button to generate passwords using the current options; tap any password row to copy it to the clipboard.
- **Clipboard safety**: optional auto-clear after copy (configurable delay).
- **Readability controls**: exclude ambiguous characters (O/0/I/l) and choose a symbol set.

## Project structure

```
Dandelion/
  App/DandelionApp.swift             SwiftUI App entry point
  Models/PasswordOptions.swift       Password policy state
  Models/PasswordGeneratorService.swift  Password generation logic
  Models/PasswordStore.swift         ObservableObject shared between views
  Views/ContentView.swift            Main view container
  Views/OptionsView.swift            Options page
  Views/PasswordListView.swift       Password list + copy/refresh
  Assets.xcassets/                   App icon / accent color placeholders
DandelionTests/
  DandelionServiceTests.swift        Unit tests
project.yml                          XcodeGen project spec
Dandelion.xcodeproj                  Generated Xcode project
```

## Building

The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`:

```bash
brew install xcodegen   # one-time
xcodegen generate
open Dandelion.xcodeproj
```

Two targets are produced: `Dandelion-iOS` and `Dandelion-macOS`, sharing the same source folder. The app's display name is `random`.

## Testing

Run macOS unit tests from Xcode (Test) or via `xcodebuild`.

## Known environment issue

On this machine, `xcodebuild` may fail to load the `IDESimulatorFoundation` plugin. If that occurs, use Xcode.app's GUI or type-check the Swift sources directly:

```bash
swiftc -typecheck -sdk $(xcrun --sdk macosx --show-sdk-path) -target arm64-apple-macosx14.0 Dandelion/App/*.swift Dandelion/Models/*.swift Dandelion/Views/*.swift
```
