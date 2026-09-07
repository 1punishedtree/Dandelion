# PasswordGenerator (pg)

A native SwiftUI password generator for iOS and macOS.

## Features

- **Options tab**: choose character sets (uppercase, lowercase, numbers, symbols), adjust password length and count with stepper (+/-) controls.
- **Presets**: Standard / Readable / Strong.
- **Passwords tab**: tap the refresh button to (re)generate passwords using the current options; tap any password row to copy it to the clipboard.
- **Clipboard safety**: optional auto-clear after copy (configurable delay).
- **Readability controls**: exclude ambiguous characters (O/0/I/l) and choose a symbol set.

## Project structure

```
PasswordGenerator/
  App/PasswordGeneratorApp.swift      SwiftUI App entry point
  Models/PasswordOptions.swift        Password policy state
  Models/PasswordGeneratorService.swift  Password generation logic
  Models/PasswordStore.swift          ObservableObject shared between tabs
  Views/ContentView.swift             TabView container
  Views/OptionsView.swift             Options page
  Views/PasswordListView.swift        Password list + copy/refresh
  Assets.xcassets/                    App icon / accent color placeholders
PasswordGeneratorTests/
  PasswordGeneratorServiceTests.swift Unit tests
.github/workflows/ci.yml              GitHub Actions CI
project.yml                           XcodeGen project spec
PasswordGenerator.xcodeproj           Generated Xcode project (do not edit sources by hand; edit project.yml then run `xcodegen generate`)
```

## Building

The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`:

```bash
brew install xcodegen   # one-time
xcodegen generate
open PasswordGenerator.xcodeproj
```

Two targets are produced: `PasswordGenerator-iOS` and `PasswordGenerator-macOS`, sharing the same source files.

## Testing

After generating the project, run macOS unit tests from Xcode (Test) or via `xcodebuild` on a working environment.

## Known environment issue

On this machine, `xcodebuild` currently fails to load the `IDESimulatorFoundation` plugin (a broken/mismatched system Xcode component, unrelated to this project's code). Fixing it requires admin privileges:

```bash
sudo xcodebuild -runFirstLaunch
```

Until that is fixed, use Xcode.app's GUI (Build/Run) instead of `xcodebuild` on the CLI, or run:

```bash
swiftc -typecheck -sdk $(xcrun --sdk macosx --show-sdk-path) -target arm64-apple-macosx14.0 PasswordGenerator/App/*.swift PasswordGenerator/Models/*.swift PasswordGenerator/Views/*.swift
```

to type-check the Swift sources without going through `xcodebuild`.
